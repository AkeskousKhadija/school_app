create table niveau (
  id_niveau serial primary key,
  nom text not null
);

create table matiere (
  id_matiere serial primary key,
  nom text not null
);

create table cours (
  id_cours serial primary key,
  id_niveau int references niveau(id_niveau) on delete cascade,
  matiere text check (matiere in ('Arabe', 'Francais')),
  titre_cours text
);

create table emploi_du_temps (
  id_emploi serial primary key,
  id_cours int references cours(id_cours) on delete cascade
);

create table seance (
  id_seance serial primary key,
  id_emploi int references emploi_du_temps(id_emploi) on delete cascade,
  contenu text,
  numero_ordre int,
  duree int
);
