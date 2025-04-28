import { assertEquals } from "https://deno.land/std@0.181.0/testing/asserts.ts";

// Test 1 : Recherche full-text par nom
Deno.test("GET /services?search=massage - full-text", async () => {
  const res = await fetch("http://localhost:8000/services?search=massage");
  const body = await res.json();
  console.log("Résultat recherche full-text:", res.status, body);
  assertEquals(res.status, 200);
  // Vérifie que tous les services contiennent "massage" dans le nom (insensible à la casse)
  for (const s of body) {
    if (!s.name.toLowerCase().includes("massage")) {
      throw new Error("Service sans le mot clé dans le nom");
    }
  }
});

// Test 2 : Filtre par catégorie
Deno.test("GET /services?category_id=cat-id-1", async () => {
  const res = await fetch("http://localhost:8000/services?category_id=cat-id-1");
  const body = await res.json();
  console.log("Résultat filtre catégorie:", res.status, body);
  assertEquals(res.status, 200);
  for (const s of body) {
    assertEquals(s.category_id, "cat-id-1");
  }
});

// Test 3 : Filtre par prix max
Deno.test("GET /services?max_price=50", async () => {
  const res = await fetch("http://localhost:8000/services?max_price=50");
  const body = await res.json();
  console.log("Résultat filtre prix max:", res.status, body);
  assertEquals(res.status, 200);
  for (const s of body) {
    if (s.price > 50) {
      throw new Error("Service avec prix > 50");
    }
  }
});

// Test 4 : Tri par popularité
Deno.test("GET /services?order_by=booking_count", async () => {
  const res = await fetch("http://localhost:8000/services?order_by=booking_count");
  const body = await res.json();
  console.log("Résultat tri popularité:", res.status, body);
  assertEquals(res.status, 200);
  let last = Number.POSITIVE_INFINITY;
  for (const s of body) {
    if (s.booking_count > last) {
      throw new Error("Non trié par popularité décroissante");
    }
    last = s.booking_count;
  }
});

// Test 5 : Pagination
Deno.test("GET /services?limit=2&offset=1", async () => {
  const res = await fetch("http://localhost:8000/services?limit=2&offset=1");
  const body = await res.json();
  console.log("Résultat pagination:", res.status, body);
  assertEquals(res.status, 200);
  if (body.length > 2) {
    throw new Error("Pagination incorrecte");
  }
});

// Test 6 : Cas d’erreur (filtre inconnu)
Deno.test("GET /services?unknown_filter=foo", async () => {
  const res = await fetch("http://localhost:8000/services?unknown_filter=foo");
  const body = await res.json();
  console.log("Erreur filtre inconnu:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Filtre inconnu : unknown_filter");
});
