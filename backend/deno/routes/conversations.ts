import { Router } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import { ConversationService } from "../services/conversation_service.ts";

const router = new Router();

// POST /conversations
router.post("/conversations", async (ctx) => {
  const { participants } = await ctx.request.body({ type: "json" }).value;
  if (!participants || !Array.isArray(participants) || participants.length < 2) {
    ctx.response.status = 400;
    ctx.response.body = { error: "participants requis (au moins 2)" };
    return;
  }
  const { conversation, error } = await ConversationService.createOrGetConversation(participants);
  if (error) {
    ctx.response.status = 400;
    ctx.response.body = { error };
  } else {
    ctx.response.status = 200;
    ctx.response.body = conversation;
  }
});

export default router;
