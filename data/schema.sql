create table if not exists trivia_clues (
  id serial primary key,
  category_id integer,
  value integer,
  clue text,
  answer text
);

create table if not exists trivia_categories (
  id serial primary key,
  name text
);
