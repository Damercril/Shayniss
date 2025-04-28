import { assertEquals } from "https://deno.land/std@0.181.0/testing/asserts.ts";

// Test 1 : Remboursement automatique à l'annulation d'une réservation payée
Deno.test("Remboursement automatique à l'annulation", async () => {
  // Création d'un paiement fictif (simulate paid booking)
  const avail = await (await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-refund-1",
      start_time: "2025-09-01T10:00:00Z",
      end_time: "2025-09-01T11:00:00Z"
    })
  })).json();
  const bookRes = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-refund-1",
      availability_id: avail.id,
      booking_date: "2025-09-01T10:00:00Z",
      paid: true,
      amount_paid: 100
    })
  });
  const booking = await bookRes.json();
  await fetch(`http://localhost:8000/bookings/${booking.id}`, { method: "DELETE" });
  // Vérifier remboursement créé
  const refundRes = await fetch(`http://localhost:8000/refunds?booking_id=${booking.id}`);
  const refunds = await refundRes.json();
  const found = refunds.some((r: any) => r.status === "remboursé" && r.amount === 100);
  console.log("Remboursement automatique:", found, refunds);
  assertEquals(found, true);
});

// Test 2 : Calcul du montant remboursé selon la politique
Deno.test("Remboursement partiel ou total selon délai", async () => {
  // Annulation >24h avant : total
  const avail1 = await (await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-refund-2",
      start_time: "2025-09-10T10:00:00Z",
      end_time: "2025-09-10T11:00:00Z"
    })
  })).json();
  const bookRes1 = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-refund-2",
      availability_id: avail1.id,
      booking_date: "2025-09-10T10:00:00Z",
      paid: true,
      amount_paid: 200
    })
  });
  const booking1 = await bookRes1.json();
  await fetch(`http://localhost:8000/bookings/${booking1.id}`, { method: "DELETE" });
  const refundRes1 = await fetch(`http://localhost:8000/refunds?booking_id=${booking1.id}`);
  const refunds1 = await refundRes1.json();
  const foundTotal = refunds1.some((r: any) => r.amount === 200 && r.policy_applied === "total");
  // Annulation <24h avant : partiel
  const avail2 = await (await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-refund-3",
      start_time: "2025-09-11T10:00:00Z",
      end_time: "2025-09-11T11:00:00Z"
    })
  })).json();
  const bookRes2 = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-refund-3",
      availability_id: avail2.id,
      booking_date: "2025-09-11T10:00:00Z",
      paid: true,
      amount_paid: 300
    })
  });
  const booking2 = await bookRes2.json();
  // Simuler une annulation <24h avant (on suppose la logique métier gère le délai)
  await fetch(`http://localhost:8000/bookings/${booking2.id}`, { method: "DELETE" });
  const refundRes2 = await fetch(`http://localhost:8000/refunds?booking_id=${booking2.id}`);
  const refunds2 = await refundRes2.json();
  const foundPartial = refunds2.some((r: any) => r.amount === 150 && r.policy_applied === "partiel");
  console.log("Remboursement total:", foundTotal, refunds1);
  console.log("Remboursement partiel:", foundPartial, refunds2);
  assertEquals(foundTotal, true);
  assertEquals(foundPartial, true);
});

// Test 3 : Notification lors du remboursement
Deno.test("Notification lors du remboursement", async () => {
  const avail = await (await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-refund-4",
      start_time: "2025-09-15T10:00:00Z",
      end_time: "2025-09-15T11:00:00Z"
    })
  })).json();
  const bookRes = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-refund-4",
      availability_id: avail.id,
      booking_date: "2025-09-15T10:00:00Z",
      paid: true,
      amount_paid: 120
    })
  });
  const booking = await bookRes.json();
  await fetch(`http://localhost:8000/bookings/${booking.id}`, { method: "DELETE" });
  // Vérifier notification remboursement
  const notifClient = await (await fetch("http://localhost:8000/notifications?user_id=client-refund-4")).json();
  const notifPro = await (await fetch("http://localhost:8000/notifications?user_id=pro-refund-4")).json();
  const foundClient = notifClient.some((n: any) => n.type === "refund_processed");
  const foundPro = notifPro.some((n: any) => n.type === "refund_processed");
  console.log("Notification remboursement client:", foundClient, notifClient);
  console.log("Notification remboursement pro:", foundPro, notifPro);
  assertEquals(foundClient, true);
  assertEquals(foundPro, true);
});

// Test 4 : Robustesse (pas de double remboursement)
Deno.test("Pas de double remboursement", async () => {
  const avail = await (await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-refund-5",
      start_time: "2025-09-20T10:00:00Z",
      end_time: "2025-09-20T11:00:00Z"
    })
  })).json();
  const bookRes = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-refund-5",
      availability_id: avail.id,
      booking_date: "2025-09-20T10:00:00Z",
      paid: true,
      amount_paid: 80
    })
  });
  const booking = await bookRes.json();
  await fetch(`http://localhost:8000/bookings/${booking.id}`, { method: "DELETE" });
  // Tentative de double remboursement
  await fetch(`http://localhost:8000/bookings/${booking.id}`, { method: "DELETE" });
  const refundRes = await fetch(`http://localhost:8000/refunds?booking_id=${booking.id}`);
  const refunds = await refundRes.json();
  const count = refunds.length;
  console.log("Nombre de remboursements (doit être 1):", count, refunds);
  assertEquals(count, 1);
});
