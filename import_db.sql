DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Nandini', 'Adhyapaka'),
  ('Matthew', 'Kerchner');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Admissions', 'What is the admissions procedure?', (SELECT id FROM users WHERE fname = 'Nandini' AND lname = 'Adhyapaka')),
  ('Coffee', 'Why is there no more coffee?', (SELECT id FROM users WHERE fname = 'Matthew' AND lname = 'Kerchner'));

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Matthew' AND lname = 'Kerchner'), (SELECT id FROM questions WHERE title = 'Coffee')),
  ((SELECT id FROM users WHERE fname = 'Nandini' AND lname = 'Adhyapaka'), (SELECT id FROM questions WHERE title = 'Admissions'));

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Matthew' AND lname = 'Kerchner'), (SELECT id FROM questions WHERE title = 'Coffee')),
  ((SELECT id FROM users WHERE fname = 'Nandini' AND lname = 'Adhyapaka'), (SELECT id FROM questions WHERE title = 'Admissions'));

INSERT INTO
  replies (body, question_id, parent_reply_id, user_id)
VALUES
  ('I don''t know', (SELECT id FROM questions WHERE title = 'Coffee'), NULL, (SELECT id FROM users WHERE fname = 'Matthew' AND lname = 'Kerchner')),
  ('I don''t know', (SELECT id FROM questions WHERE title = 'Coffee'), NULL, (SELECT id FROM users WHERE fname = 'Nandini' AND lname = 'Adhyapaka'));
