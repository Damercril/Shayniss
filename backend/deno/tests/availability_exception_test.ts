import { assertEquals } from "https://deno.land/std@0.181.0/testing/asserts.ts";

// Test 1 : Création d'une exception valide
Deno.test("POST /availability_exceptions - succès", async () => {
  // Suppose qu'un créneau existe déjà
  const avail = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-1",
      start_time: "2025-05-10T09:00:00Z",
      end_time: "2025-05-10T12:00:00Z"
    })
  });
  const a = await avail.json();
  const res = await fetch("http://localhost:8000/availability_exceptions", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      availability_id: a.id,
      exception_date: "2025-05-10"
    })
  });
  const body = await res.json();
  console.log("Création exception:", res.status, body);
  assertEquals(res.status, 201);
  assertEquals(body.availability_id, a.id);
});

// Test 2 : Création exception sur créneau inexistant
Deno.test("POST /availability_exceptions - créneau inexistant", async () => {
  const res = await fetch("http://localhost:8000/availability_exceptions", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      availability_id: "id-inexistant",
      exception_date: "2025-05-11"
    })
  });
  const body = await res.json();
  console.log("Erreur créneau inexistant:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Créneau de disponibilité inexistant");
});

// Test 3 : Création exception hors créneau
Deno.test("POST /availability_exceptions - hors créneau", async () => {
  // Suppose qu'un créneau existe du 10 mai 9h au 10 mai 12h
  const avail = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-2",
      start_time: "2025-05-10T09:00:00Z",
      end_time: "2025-05-10T12:00:00Z"
    })
  });
  const a = await avail.json();
  const res = await fetch("http://localhost:8000/availability_exceptions", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      availability_id: a.id,
      exception_date: "2025-05-11"
    })
  });
  const body = await res.json();
  console.log("Erreur exception hors créneau:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Date d'exception hors plage du créneau");
});

// Test 4 : Liste des exceptions pour un créneau
Deno.test("GET /availability_exceptions?availability_id=...", async () => {
  // Suppose qu'une exception existe déjà
  const avail = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-3",
      start_time: "2025-05-12T09:00:00Z",
      end_time: "2025-05-12T12:00:00Z"
    })
  });
  const a = await avail.json();
  await fetch("http://localhost:8000/availability_exceptions", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      availability_id: a.id,
      exception_date: "2025-05-12"
    })
  });
  const res = await fetch(`http://localhost:8000/availability_exceptions?availability_id=${a.id}`);
  const body = await res.json();
  console.log("Liste exceptions:", res.status, body);
  assertEquals(res.status, 200);
  for (const e of body) {
    assertEquals(e.availability_id, a.id);
  }
});

// Test 5 : Suppression d'une exception
Deno.test("DELETE /availability_exceptions/:id", async () => {
  // Suppose qu'une exception existe déjà
  const avail = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-4",
      start_time: "2025-05-13T09:00:00Z",
      end_time: "2025-05-13T12:00:00Z"
    })
  });
  const a = await avail.json();
  const create = await fetch("http://localhost:8000/availability_exceptions", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      availability_id: a.id,
      exception_date: "2025-05-13"
    })
  });
  const e = await create.json();
  const res = await fetch(`http://localhost:8000/availability_exceptions/${e.id}`, {
    method: "DELETE"
  });
  console.log("Suppression exception:", res.status);
  assertEquals(res.status, 204);
});

// Test 6 : Erreur doublon exception
Deno.test("POST /availability_exceptions - doublon", async () => {
  // Suppose qu'une exception existe déjà
  const avail = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-5",
      start_time: "2025-05-14T09:00:00Z",
      end_time: "2025-05-14T12:00:00Z"
    })
  });
  const a = await avail.json();
  await fetch("http://localhost:8000/availability_exceptions", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      availability_id: a.id,
      exception_date: "2025-05-14"
    })
  });
  const res = await fetch("http://localhost:8000/availability_exceptions", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      availability_id: a.id,
      exception_date: "2025-05-14"
    })
  });
  const body = await res.json();
  console.log("Erreur doublon exception:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Exception déjà existante pour cette date");
});
