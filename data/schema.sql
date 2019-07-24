create table if not exists trivia_clues (
  id integer primary key,
  category_id integer,
  value integer,
  clue text,
  answer text
);

create table if not exists trivia_categories (
  id integer primary key,
  name text
);
