-- Migrations will appear here as you chat with AI

create table users (
  id bigint primary key generated always as identity,
  username text unique not null,
  email text unique not null,
  password_hash text not null,
  role text check (role in ('student', 'teacher', 'parent')) not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table students (
  id bigint primary key generated always as identity,
  user_id bigint references users (id),
  first_name text not null,
  last_name text not null,
  grade int not null,
  subjects json,
  parent_id bigint references users (id)
);

create table teachers (
  id bigint primary key generated always as identity,
  user_id bigint references users (id),
  first_name text not null,
  last_name text not null,
  subjects json,
  biography text,
  verified boolean default false
);

create table parents (
  id bigint primary key generated always as identity,
  user_id bigint references users (id),
  first_name text not null,
  last_name text not null,
  child_ids json
);

create table materials (
  id bigint primary key generated always as identity,
  teacher_id bigint references teachers (id),
  title text not null,
  description text,
  type text check (
    type in ('video', 'article', 'quiz', 'problem_set')
  ) not null,
  content text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table quizzes (
  id bigint primary key generated always as identity,
  material_id bigint references materials (id),
  questions json
);

create table sessions (
  id bigint primary key generated always as identity,
  student_id bigint references students (id),
  teacher_id bigint references teachers (id),
  scheduled_at timestamptz not null,
  duration int not null,
  status text check (status in ('scheduled', 'completed', 'cancelled')) not null,
  recording_url text
);

create table feedback (
  id bigint primary key generated always as identity,
  session_id bigint references sessions (id),
  student_id bigint references students (id),
  teacher_id bigint references teachers (id),
  rating int check (rating between 1 and 5),
  comment text,
  created_at timestamptz default now()
);

create table student_progress (
  id bigint primary key generated always as identity,
  student_id bigint references students (id),
  subject text not null,
  quiz_scores json,
  completed_assignments json,
  created_at timestamptz default now()
);

create table teacher_reports (
  id bigint primary key generated always as identity,
  teacher_id bigint references teachers (id),
  student_feedback json,
  session_count int,
  average_rating double precision,
  created_at timestamptz default now()
);

create table parent_reports (
  id bigint primary key generated always as identity,
  parent_id bigint references parents (id),
  child_id bigint references students (id),
  activity_summary text,
  progress json,
  created_at timestamptz default now()
);

alter table students
add constraint unique_user_id unique (user_id);

create table student_grades (
  id bigint primary key generated always as identity,
  student_id bigint references students (id),
  subject text not null,
  grade int check (grade between 0 and 100),
  term text not null,
  year int not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create view public_student_grades as
select
  (s.first_name || ' ') || s.last_name as student_name,
  sg.subject,
  sg.grade,
  sg.term,
  sg.year
from
  student_grades sg
  join students s on sg.student_id = s.id;
