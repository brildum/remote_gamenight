
create table if not exists slack_teams (
  slack_team_id text primary key,
  slack_team_name text,
  slack_user_id text,
  slack_user_token text,
  slack_bot_id text,
  slack_bot_token text
);

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

