// Minimal MCP JSON-RPC dispatcher (JSON mode for Streamable HTTP).
// Stateless and read-only — well suited to hosting as a remote MCP. The stdio build still uses the official SDK.
import { TOOL_DEFS, callTool, type Catalog } from './tools.js';

const PROTOCOL_VERSION = '2024-11-05';

type JsonRpcReq = { jsonrpc: '2.0'; id?: number | string | null; method: string; params?: any };
type JsonRpcRes = { jsonrpc: '2.0'; id: number | string | null; result?: unknown; error?: { code: number; message: string } };

export type DispatchResult = { response: JsonRpcRes | null; isInitialize: boolean };

export function dispatch(catalog: Catalog, msg: JsonRpcReq): DispatchResult {
  const id = msg.id ?? null;
  const reply = (result: unknown): DispatchResult => ({ response: { jsonrpc: '2.0', id, result }, isInitialize: msg.method === 'initialize' });
  const fail = (code: number, message: string): DispatchResult => ({ response: { jsonrpc: '2.0', id, error: { code, message } }, isInitialize: false });

  switch (msg.method) {
    case 'initialize':
      return reply({
        protocolVersion: PROTOCOL_VERSION,
        capabilities: { tools: {} },
        serverInfo: { name: 'flutter-motion-kit', version: '0.1.0' },
      });

    // Notifications need no reply
    case 'notifications/initialized':
    case 'notifications/cancelled':
      return { response: null, isInitialize: false };

    case 'ping':
      return reply({});

    case 'tools/list':
      return reply({ tools: TOOL_DEFS });

    case 'tools/call': {
      const name = msg.params?.name;
      const args = msg.params?.arguments ?? {};
      try {
        const data = callTool(catalog, name, args);
        return reply({ content: [{ type: 'text', text: JSON.stringify(data, null, 2) }] });
      } catch (e) {
        return reply({ content: [{ type: 'text', text: String((e as Error).message) }], isError: true });
      }
    }

    default:
      return fail(-32601, `Method not found: ${msg.method}`);
  }
}
