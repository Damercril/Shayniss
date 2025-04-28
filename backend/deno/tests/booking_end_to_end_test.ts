import { assertEquals } from "https://deno.land/std@0.181.0/testing/asserts.ts";

// Test 1 : Création et annulation standard
Deno.test("Création et annulation standard", async () => {
  // Création
  const avail = await (await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-e2e-1",
      start_time: "2025-10-01T10:00:00Z",
      end_time: "2025-10-01T11:00:00Z"
    })
  })).json();
  const bookRes = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-e2e-1",
      availability_id: avail.id,
      booking_date: "2025-10-01T10:00:00Z",
      paid: true,
      amount_paid: 100
    })
  });
  const booking = await bookRes.json();
  // Annulation
  await fetch(`http://localhost:8000/bookings/${booking.id}`, { method: "DELETE" });
  // Vérifier statut, notifications, remboursement
  const { status } = await (await fetch(`http://localhost:8000/bookings/${booking.id}`)).json();
  const notifClient = await (await fetch("http://localhost:8000/notifications?user_id=client-e2e-1")).json();
  const notifPro = await (await fetch("http://localhost:8000/notifications?user_id=pro-e2e-1")).json();
  const refunds = await (await fetch(`http://localhost:8000/refunds?booking_id=${booking.id}`)).json();
  const foundNotif = notifClient.some((n: any) => n.type === "booking_cancelled") && notifPro.some((n: any) => n.type === "booking_cancelled");
  const foundRefund = refunds.some((r: any) => r.status === "remboursé");
  console.log("Statut annulation:", status);
  console.log("Notifications:", foundNotif, notifClient, notifPro);
  console.log("Remboursement:", foundRefund, refunds);
  assertEquals(status, "cancelled");
  assertEquals(foundNotif, true);
  assertEquals(foundRefund, true);
});

// Test 2 : Conflit de réservation
Deno.test("Conflit de réservation", async () => {
  const avail = await (await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-e2e-2",
      start_time: "2025-10-02T10:00:00Z",
      end_time: "2025-10-02T11:00:00Z"
    })
  })).json();
  const bookRes1 = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-e2e-2a",
      availability_id: avail.id,
      booking_date: "2025-10-02T10:00:00Z"
    })
  });
  const bookRes2 = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-e2e-2b",
      availability_id: avail.id,
      booking_date: "2025-10-02T10:00:00Z"
    })
  });
  const result1 = await bookRes1.json();
  const result2 = await bookRes2.json();
  console.log("Première réservation:", result1);
  console.log("Tentative de conflit:", result2);
  assertEquals(result1.error, undefined);
  assertEquals(!!result2.error, true);
});

// Test 3 : Annulation par le professionnel
Deno.test("Annulation par le professionnel", async () => {
  const avail = await (await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-e2e-3",
      start_time: "2025-10-03T10:00:00Z",
      end_time: "2025-10-03T11:00:00Z"
    })
  })).json();
  const bookRes = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-e2e-3",
      availability_id: avail.id,
      booking_date: "2025-10-03T10:00:00Z",
      paid: true,
      amount_paid: 90
    })
  });
  const booking = await bookRes.json();
  // Annulation par le pro (simulate endpoint spécifique si existant, sinon DELETE classique)
  await fetch(`http://localhost:8000/bookings/${booking.id}?by=pro`, { method: "DELETE" });
  const notifClient = await (await fetch("http://localhost:8000/notifications?user_id=client-e2e-3")).json();
  const notifPro = await (await fetch("http://localhost:8000/notifications?user_id=pro-e2e-3")).json();
  const refunds = await (await fetch(`http://localhost:8000/refunds?booking_id=${booking.id}`)).json();
  const foundNotif = notifClient.some((n: any) => n.type === "booking_cancelled") && notifPro.some((n: any) => n.type === "booking_cancelled");
  const foundRefund = refunds.some((r: any) => r.status === "remboursé");
  console.log("Notifications:", foundNotif, notifClient, notifPro);
  console.log("Remboursement:", foundRefund, refunds);
  assertEquals(foundNotif, true);
  assertEquals(foundRefund, true);
});

// Test 4 : Robustesse (annulation déjà annulée, remboursement non payé)
Deno.test("Robustesse des annulations et remboursements", async () => {
  // Annulation déjà annulée
  const avail = await (await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-e2e-4",
      start_time: "2025-10-04T10:00:00Z",
      end_time: "2025-10-04T11:00:00Z"
    })
  })).json();
  const bookRes = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-e2e-4",
      availability_id: avail.id,
      booking_date: "2025-10-04T10:00:00Z",
      paid: true,
      amount_paid: 80
    })
  });
  const booking = await bookRes.json();
  await fetch(`http://localhost:8000/bookings/${booking.id}`, { method: "DELETE" });
  // Tentative de réannulation
  const delRes = await fetch(`http://localhost:8000/bookings/${booking.id}`, { method: "DELETE" });
  const delJson = await delRes.json();
  // Réservation non payée
  const avail2 = await (await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-e2e-4b",
      start_time: "2025-10-05T10:00:00Z",
      end_time: "2025-10-05T11:00:00Z"
    })
  })).json();
  const bookRes2 = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-e2e-4b",
      availability_id: avail2.id,
      booking_date: "2025-10-05T10:00:00Z",
      paid: false,
      amount_paid: 0
    })
  });
  const booking2 = await bookRes2.json();
  await fetch(`http://localhost:8000/bookings/${booking2.id}`, { method: "DELETE" });
  const refunds2 = await (await fetch(`http://localhost:8000/refunds?booking_id=${booking2.id}`)).json();
  console.log("Réannulation (doit être déjà annulée):", delJson);
  console.log("Remboursement non payé (doit être vide):", refunds2);
  assertEquals(delJson.alreadyCancelled, true);
  assertEquals(refunds2.length, 0);
});

// Test 5 : Notifications cohérentes
Deno.test("Notifications cohérentes pour chaque action", async () => {
  const avail = await (await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-e2e-5",
      start_time: "2025-10-06T10:00:00Z",
      end_time: "2025-10-06T11:00:00Z"
    })
  })).json();
  const bookRes = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-e2e-5",
      availability_id: avail.id,
      booking_date: "2025-10-06T10:00:00Z"
    })
  });
  const booking = await bookRes.json();
  await fetch(`http://localhost:8000/bookings/${booking.id}`, { method: "DELETE" });
  const notifClient = await (await fetch("http://localhost:8000/notifications?user_id=client-e2e-5")).json();
  const notifPro = await (await fetch("http://localhost:8000/notifications?user_id=pro-e2e-5")).json();
  const foundClient = notifClient.some((n: any) => n.type === "booking_cancelled");
  const foundPro = notifPro.some((n: any) => n.type === "booking_cancelled");
  console.log("Notifications client:", notifClient);
  console.log("Notifications pro:", notifPro);
  assertEquals(foundClient, true);
  assertEquals(foundPro, true);
});
