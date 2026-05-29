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
  id_matiere int references matiere(id_matiere) on delete cascade
);

create table titre_cours (
  id_titre serial primary key,
  nom text not null,
  id_cours int references cours(id_cours) on delete cascade
);

create table seance (
  id_seance serial primary key,
  contenu text,
  numero_ordre int,
  duree int,
  id_titre int references titre_cours(id_titre) on delete cascade
);

create table jour (
  id_jour serial primary key,
  nom text,
  numero int check (numero between 1 and 6)
);

create table horaire (
  id_horaire serial primary key,
  heure_debut time,
  heure_fin time
);

create table emploi_du_temps (
  id_emploi serial primary key,
  id_cours int references cours(id_cours) on delete cascade,
  id_jour int references jour(id_jour) on delete cascade,
  id_horaire int references horaire(id_horaire) on delete cascade,
  id_seance int references seance(id_seance) on delete cascade
);
