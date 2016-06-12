defmodule SlackAnonymiser do
  def serialize(data) do
    data
    |> Map.drop([:client, :socket])
    |> inspect(pretty: true, limit: 2000)
  end

  def anonymise(data) do
    data
    |> anonymise_users
    |> anonymise_me
    |> anonymise_team
  end

  defp anonymise_users(data) do
    user_ids = data |> Map.get(:users) |> Map.keys

    List.foldl user_ids, data, fn (user_id, data) ->
      data
      |> update_in([:users, user_id], &anonymise_user/1)
    end
  end

  defp anonymise_user(user) do
    first_name = Faker.Name.first_name
    last_name = Faker.Name.last_name
    full_name = "#{first_name} #{last_name}"

    user
    |> put_in([:name],                            first_name)
    |> put_in([:real_name],                       full_name)
    |> put_in([:title],                           Faker.Name.title)
    |> put_in([:profile, :email],                 Faker.Internet.email)
    |> put_in([:profile, :fields],                %{})
    |> put_in([:profile, :first_name],            first_name)
    |> put_in([:profile, :last_name],             last_name)
    |> put_in([:profile, :phone],                 Faker.Phone.EnGb.number)
    |> put_in([:profile, :real_name],             full_name)
    |> put_in([:profile, :real_name_normalized],  full_name)
    |> put_in([:profile, :skype],                 Faker.Internet.user_name)
  end

  defp anonymise_me(data) do
    update_in data, [:me], fn (me) ->
      me
      |> put_in([:name], Faker.Internet.user_name)
      |> put_in([:prefs], %{})
    end
  end

  defp anonymise_team(data) do
    update_in data, [:team], fn (team) ->
      team
      |> put_in([:domain], Faker.Internet.domain_word)
      |> put_in([:email_domain], Faker.Internet.name)
      |> put_in([:prefs], %{})
    end
  end
end
