import { Router } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import { RefundService } from "../services/refund_service.ts";

const router = new Router();

// GET /refunds?booking_id=...
router.get("/refunds", async (ctx) => {
  const booking_id = ctx.request.url.searchParams.get("booking_id");
  if (!booking_id) {
    ctx.response.status = 400;
    ctx.response.body = { error: "booking_id requis" };
    return;
  }
  const { refunds, error } = await RefundService.listRefunds(booking_id);
  if (error) {
    ctx.response.status = 400;
    ctx.response.body = { error };
  } else {
    ctx.response.status = 200;
    ctx.response.body = refunds;
  }
});

export default router;
