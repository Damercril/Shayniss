import { Router } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import { NotificationService } from "../services/notification_service.ts";

const router = new Router();

// GET /notifications?user_id=...
router.get("/notifications", async (ctx) => {
  const user_id = ctx.request.url.searchParams.get("user_id");
  if (!user_id) {
    ctx.response.status = 400;
    ctx.response.body = { error: "user_id requis" };
    return;
  }
  const { notifications, error } = await NotificationService.listNotifications(user_id);
  if (error) {
    ctx.response.status = 400;
    ctx.response.body = { error };
  } else {
    ctx.response.status = 200;
    ctx.response.body = notifications;
  }
});

export default router;
