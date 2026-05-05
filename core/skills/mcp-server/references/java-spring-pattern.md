# Java Spring Boot MCP Pattern

Reference implementation based on a Spring Boot + NATS system. Adapt the transport layer (NATS → HTTP/gRPC/etc.) as needed — the annotation model and auto-discovery are reusable regardless of transport.

---

## Annotations

Three custom annotations drive the entire tool system:

**`@McpToolProvider`** (class-level) — marks a class as a tool provider. Extends `@Component` so Spring picks it up automatically.

**`@McpTool`** (method-level) — marks a method as an MCP tool:
```java
@McpTool(
    name = "search_orders",
    description = "Search orders by status. Use before get_order to locate the id. "
                + "Does not return line item detail — use get_order for that.",
    category = "orders",
    permission = "permission.orders.get",      // optional — omit if no permission model
    permissionApplication = "order-service"    // required when permission is set
)
```

**`@ToolParam`** (parameter-level):
```java
@ToolParam(name = "status", description = "Filter by status (PENDING, ACTIVE, CLOSED)", required = false)
```

---

## Auto-Discovery (ToolRegistry)

`ToolRegistry` runs at startup (`@PostConstruct`), scans all `@McpToolProvider` beans via `ApplicationContext.getBeansWithAnnotation()`, and builds a `ToolDefinition` map.

Key detail: use `AopUtils.getTargetClass(provider)` when scanning methods — Spring proxies (e.g., from `@WithSpan` AOP) wrap the bean, hiding the annotations on the real class.

---

## Three-File Pattern Per Domain

```
{domain}/
  {Domain}Tools.java           ← tool declarations + business logic
  {Domain}Service.java         ← external communication (NATS / HTTP / DB)
  {Domain}SubjectConfig.java   ← @ConfigurationProperties for NATS subjects
```

### Tools class skeleton:
```java
@Component
@McpToolProvider
@Slf4j
@RequiredArgsConstructor
@ConditionalOnProperty(name = "mcp.tools.{domain}.enabled", havingValue = "true", matchIfMissing = true)
public class {Domain}Tools {

    private final {Domain}Service service;
    private final ObjectMapper objectMapper;

    @McpTool(name = "...", description = "...")
    @WithSpan("mcp.tool.{tool_name}")
    public JsonNode myTool(
        @ToolParam(name = "bankId", description = "The bank identifier", required = true) String bankId,
        @ToolParam(name = "token", description = "JWT authorization token", required = true) String token) {
        // token is injected by McpService — hidden from LLM schema automatically
        return service.doSomething(bankId, token);
    }
}
```

### Service class skeleton (NATS transport):
```java
@Service
@Slf4j
@RequiredArgsConstructor
public class {Domain}Service {

    private final NatsRequestClient natsRequestClient;
    private final NatsSubjectConfig sharedConfig;
    private final {Domain}SubjectConfig config;
    private final ObjectMapper objectMapper;

    public JsonNode getSomething(String id, String token) {
        String subject = String.format(config.getGetSomething(), id);
        return sendRequest(subject, null, token);
    }

    private JsonNode sendRequest(String subject, byte[] data, String token) {
        Headers headers = new Headers();
        headers.put("Authorization", "Bearer " + token);
        NatsMessage msg = NatsMessage.builder().subject(subject).headers(headers).data(data).build();
        Message response = natsRequestClient.request(msg, Duration.ofSeconds(sharedConfig.getTimeoutSecs()));
        return objectMapper.readTree(response.getData());
    }
}
```

### SubjectConfig skeleton:
```java
@Configuration
@ConfigurationProperties(prefix = "nats.subjects.{domain}")
@Getter @Setter
public class {Domain}SubjectConfig {
    /** get.{Resource}.{id} */
    private String getSomething = "get.{Resource}.%s";
    /** post.{Resource}.find */
    private String searchSomething = "post.{Resource}.find";
}
```

---

## application.yml additions

```yaml
nats.subjects.{domain}:
  getSomething: "get.{Resource}.%s"
  searchSomething: "post.{Resource}.find"

mcp.tools.{domain}.enabled: true
```

---

## Token Injection

The `token` `@ToolParam` is declared on every tool method, but `McpService.buildMcpTool()` skips parameters named `"token"` or `"authToken"` when building the LLM-facing schema. The token is injected into the argument map by `McpService.callTool()` before the tool method is invoked. No change needed to the Tools class.

---

## Permission Filtering

`McpService.listTools()` calls `PermissionClient.validateUserOrServicePermission()` for each tool that declares a `permission`. Tools the user lacks are filtered from the list — the LLM never sees them.

---

## NATS Subject Naming Convention

`{verb}.{Resource}.{SubResource}.{detail}` — e.g.:
- `get.Orders.%s` — get one order by id
- `post.Orders.find` — search orders
- `post.Orders.Banks.%s.Profiles` — create profile for a bank
- `put.Orders.Banks.%s.Profiles.%s` — update profile by id
