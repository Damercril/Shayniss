-- Mise à jour des contraintes de la table services
alter table services
  alter column name set not null,
  alter column name set default '',
  alter column professional_id set not null,
  alter column professional_id set default '',
  alter column price set not null,
  alter column price set default 0,
  alter column duration_minutes set not null,
  alter column duration_minutes set default 0,
  alter column is_active set not null,
  alter column is_active set default true,
  alter column booking_count set not null,
  alter column booking_count set default 0,
  alter column created_at set not null,
  alter column created_at set default now(),
  alter column updated_at set not null,
  alter column updated_at set default now();

-- Ajout des contraintes de validation
alter table services
  add constraint services_name_length check (length(name) > 0),
  add constraint services_price_positive check (price >= 0),
  add constraint services_duration_positive check (duration_minutes >= 0),
  add constraint services_booking_count_positive check (booking_count >= 0);

-- Mise à jour des triggers pour la gestion des dates
create or replace function services_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists set_services_updated_at on services;
create trigger set_services_updated_at
  before update on services
  for each row
  execute function services_updated_at();

-- Ajout d'un index pour améliorer les performances de recherche
create index if not exists idx_services_search
  on services using gin(
    to_tsvector('french',
      coalesce(name, '') || ' ' ||
      coalesce(description, '') || ' ' ||
      coalesce(category, '')
    )
  );

-- Ajout d'un index composite pour les filtres courants
create index if not exists idx_services_filters
  on services(professional_id, is_active, category)
  where is_active = true;
