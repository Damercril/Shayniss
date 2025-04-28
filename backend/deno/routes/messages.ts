import { Router } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import { MessageService } from "../services/message_service.ts";

const router = new Router();

// POST /messages
router.post("/messages", async (ctx) => {
  const { conversation_id, sender_id, content } = await ctx.request.body({ type: "json" }).value;
  if (!conversation_id || !sender_id || !content) {
    ctx.response.status = 400;
    ctx.response.body = { error: "conversation_id, sender_id et content requis" };
    return;
  }
  const { message, error } = await MessageService.sendMessage(conversation_id, sender_id, content);
  if (error) {
    ctx.response.status = 400;
    ctx.response.body = { error };
  } else {
    ctx.response.status = 200;
    ctx.response.body = message;
  }
});

// GET /messages?conversation_id=...&user_id=...&limit=...&offset=...
router.get("/messages", async (ctx) => {
  const conversation_id = ctx.request.url.searchParams.get("conversation_id");
  const user_id = ctx.request.url.searchParams.get("user_id");
  const limit = parseInt(ctx.request.url.searchParams.get("limit") || "10");
  const offset = parseInt(ctx.request.url.searchParams.get("offset") || "0");
  if (!conversation_id || !user_id) {
    ctx.response.status = 400;
    ctx.response.body = { error: "conversation_id et user_id requis" };
    return;
  }
  const { messages, error } = await MessageService.listMessages(conversation_id, user_id, limit, offset);
  if (error) {
    ctx.response.status = 400;
    ctx.response.body = { error };
  } else {
    ctx.response.status = 200;
    ctx.response.body = messages;
  }
});

// DELETE /messages/:conversation_id?user_id=...
router.delete("/messages/:conversation_id", async (ctx) => {
  const conversation_id = ctx.params.conversation_id;
  const user_id = ctx.request.url.searchParams.get("user_id");
  if (!conversation_id || !user_id) {
    ctx.response.status = 400;
    ctx.response.body = { error: "conversation_id et user_id requis" };
    return;
  }
  const { deleted, error } = await MessageService.deleteMessages(conversation_id, user_id);
  if (error) {
    ctx.response.status = 400;
    ctx.response.body = { error };
  } else {
    ctx.response.status = 200;
    ctx.response.body = { deleted };
  }
});

export default router;
