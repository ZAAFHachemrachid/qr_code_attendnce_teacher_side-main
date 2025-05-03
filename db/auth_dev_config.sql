-- Function to auto-confirm new users in development
create or replace function auth.handle_new_user()
returns trigger as $$
begin
  if new.email like '%@gmail.com' then
    -- Auto confirm email for development accounts
    update auth.users set
      email_confirmed_at = now(),
      confirmed_at = now()
    where id = new.id;
  end if;
  return new;
end;
$$ language plpgsql security definer;

-- Create the trigger if it doesn't exist
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function auth.handle_new_user();

-- Update auth configuration
alter table auth.users alter column email_confirmed_at set default now();
alter table auth.users alter column confirmed_at set default now();

-- Confirm any existing development accounts
update auth.users set
  email_confirmed_at = now(),
  confirmed_at = now()
where email like '%@gmail.com'
  and (email_confirmed_at is null or confirmed_at is null);