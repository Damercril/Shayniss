import { assertEquals } from "https://deno.land/std@0.181.0/testing/asserts.ts";

// Test 1 : Création d'une disponibilité valide
Deno.test("POST /availabilities - succès", async () => {
  const res = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-1",
      start_time: "2025-05-01T10:00:00Z",
      end_time: "2025-05-01T12:00:00Z"
    })
  });
  const body = await res.json();
  console.log("Création disponibilité:", res.status, body);
  assertEquals(res.status, 201);
  assertEquals(body.professional_id, "pro-1");
});

// Test 2 : Création avec chevauchement
Deno.test("POST /availabilities - chevauchement", async () => {
  // On suppose qu'un créneau 10h-12h existe déjà
  await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-1",
      start_time: "2025-05-01T10:00:00Z",
      end_time: "2025-05-01T12:00:00Z"
    })
  });
  const res = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-1",
      start_time: "2025-05-01T11:00:00Z",
      end_time: "2025-05-01T13:00:00Z"
    })
  });
  const body = await res.json();
  console.log("Erreur chevauchement:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Créneau en conflit");
});

// Test 3 : Création avec professional_id inexistant
Deno.test("POST /availabilities - pro inexistant", async () => {
  const res = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-inexistant",
      start_time: "2025-05-01T14:00:00Z",
      end_time: "2025-05-01T15:00:00Z"
    })
  });
  const body = await res.json();
  console.log("Erreur pro inexistant:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Professionnel inexistant");
});

// Test 4 : GET /availabilities/:id existant
Deno.test("GET /availabilities/:id - succès", async () => {
  const create = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-2",
      start_time: "2025-05-01T16:00:00Z",
      end_time: "2025-05-01T17:00:00Z"
    })
  });
  const created = await create.json();
  const res = await fetch(`http://localhost:8000/availabilities/${created.id}`);
  const body = await res.json();
  console.log("Récupération disponibilité:", res.status, body);
  assertEquals(res.status, 200);
  assertEquals(body.id, created.id);
});

// Test 5 : PATCH /availabilities/:id (modification)
Deno.test("PATCH /availabilities/:id - succès", async () => {
  const create = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-3",
      start_time: "2025-05-01T18:00:00Z",
      end_time: "2025-05-01T19:00:00Z"
    })
  });
  const created = await create.json();
  const res = await fetch(`http://localhost:8000/availabilities/${created.id}`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ end_time: "2025-05-01T20:00:00Z" })
  });
  const body = await res.json();
  console.log("Modification disponibilité:", res.status, body);
  assertEquals(res.status, 200);
  assertEquals(body.end_time, "2025-05-01T20:00:00Z");
});

// Test 6 : DELETE /availabilities/:id
Deno.test("DELETE /availabilities/:id - succès", async () => {
  const create = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-4",
      start_time: "2025-05-01T21:00:00Z",
      end_time: "2025-05-01T22:00:00Z"
    })
  });
  const created = await create.json();
  const res = await fetch(`http://localhost:8000/availabilities/${created.id}`, {
    method: "DELETE"
  });
  console.log("Suppression disponibilité:", res.status);
  assertEquals(res.status, 204);
});

// Test 7 : GET /availabilities?pro=pro-1&day=4
Deno.test("GET /availabilities?pro=pro-1&day=4", async () => {
  const res = await fetch("http://localhost:8000/availabilities?pro=pro-1&day=4");
  const body = await res.json();
  console.log("Liste filtrée:", res.status, body);
  assertEquals(res.status, 200);
  for (const a of body) {
    assertEquals(a.professional_id, "pro-1");
    // Optionnel : vérifier day_of_week si présent
  }
});

// Test 8 : Erreurs horaires/id inconnu
Deno.test("POST /availabilities - horaires incohérents", async () => {
  const res = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-5",
      start_time: "2025-05-01T23:00:00Z",
      end_time: "2025-05-01T22:00:00Z"
    })
  });
  const body = await res.json();
  console.log("Erreur horaires incohérents:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "L'heure de fin doit être postérieure à l'heure de début.");
});
