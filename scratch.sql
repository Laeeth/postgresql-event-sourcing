create or replace function fn_event_insert() returns trigger
  security definer
  language plpgsql
as $$
  begin
	if new.body ?& array['blah'] then
		insert into users(id, name, inserted_at, updated_at)
		  values(new.id, new.body->>'blah', NOW(), NOW())
		on conflict (id) do
			update SET name = new.body->>'blah', updated_at = NOW()
			where users.id = new.id;
	end if;
	return new;
  end;
$$;

create or replace function fn_event_insert_action(event jsonb) returns integer
  security definer
  language plpgsql
as $$
  declare return_id int;
  begin
	 insert into users(id, name, inserted_at, updated_at)
	    values((event->>'id')::int, event->>'name', NOW(), NOW())
	 RETURNING id into return_id;
	 return return_id;
  end;
$$;


SELECT fn_event_insert_action(body) FROM events LIMIT 1;
