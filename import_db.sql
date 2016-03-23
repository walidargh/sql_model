DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_likes;


CREATE TABLE users
(
  fname varchar(255),
  lname varchar(255),
  id INTEGER PRIMARY KEY
);

CREATE TABLE questions
(
  title varchar(255),
  body text,
  user_id INTEGER,
  id INTEGER PRIMARY KEY,
  FOREIGN KEY (user_id) references users (id)
);

CREATE TABLE question_follows
(
  user_id INTEGER,
  question_id INTEGER,
  id INTEGER PRIMARY KEY,
  FOREIGN KEY (user_id) references users (id),
  FOREIGN KEY (question_id) references questions (id)
);

CREATE TABLE replies
(
  body text,
  question_id INTEGER,
  user_id INTEGER,
  parent_id INTEGER,
  id INTEGER PRIMARY KEY,
  FOREIGN KEY (question_id) references questions (id),
  FOREIGN KEY (user_id) references users (id),
  FOREIGN KEY (parent_id) references replies (id)
);

CREATE TABLE question_likes
(
  user_id INTEGER,
  question_id INTEGER,
  id INTEGER PRIMARY KEY,
  FOREIGN KEY (user_id) references users (id),
  FOREIGN KEY (question_id) references questions (id)
);

INSERT INTO
  users (fname, lname)
  VALUES
    ('John', 'Doe'), ('Jane', 'Doe');

INSERT INTO
  questions (title, body, user_id)
  VALUES
    ('How to code?', 'Coding is hard', 1);

INSERT INTO
  question_likes (user_id, question_id)
  VALUES
    (1, 1);
