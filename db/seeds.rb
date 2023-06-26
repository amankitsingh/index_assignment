return if Rails.env.production?

# NOTE: when adding new data, please use the Seeder class to ensure the seed tasks
# stays idempotent.
require Rails.root.join("app/lib/seeder")

# we use this to be able to increase the size of the seeded DB at will
# eg.: `SEEDS_MULTIPLIER=2 rails db:seed` would double the amount of data
seeder = Seeder.new
SEEDS_MULTIPLIER = [1, ENV["SEEDS_MULTIPLIER"].to_i].max
puts "Seeding with multiplication factor: #{SEEDS_MULTIPLIER}\n\n"

# Disable Redis cache while seeding
Rails.cache = ActiveSupport::Cache.lookup_store(:null_store)

seeder.create_if_none(User) do
		1.times do
			begin
				user = User.create!(
					first_name: Faker::Name.first_name.downcase,
					last_name: Faker::Name.last_name.downcase,
					email: Faker::Internet.email.downcase,
					encrypted_password: Faker::Internet.password,
					role: "admin",
					status: "active"
				)
	
				ApiSecret.create!(
					secret: "f8ea2bf80416732ab4ad71345cdff1d6",
					user_id: user.id,
					description: "This is the only admin user in the app"
				)
			rescue => e
				next
			end
		end
		puts "Admin User created" if User.where(role: "admin").present?

		3.times do
			begin
				user = User.create!(
					first_name: Faker::Name.first_name.downcase,
					last_name: Faker::Name.last_name.downcase,
					email: Faker::Internet.email.downcase,
					encrypted_password: Faker::Internet.password,
					role: "user"
				)
				ApiSecret.create!(
					secret: SecureRandom.hex,
					user_id: user.id,
					description: Faker::Markdown.emphasis
				)
			rescue => e
				next
			end
		end
		puts "Other User created #{User.all.count - 1}"
end

# seeder.create_if_none(Category) do
# 	10.times do
# 		begin
# 			Category.create(
# 				name: Faker::Lorem.word
# 			)
# 		rescue => e
# 			next
# 		end
# 	end
# 	puts "Category Created #{Category.all.count}"
# end

# seeder.create_if_none(Tag) do
# 	5.times do
# 		begin
# 			Tag.create(
# 				name: Faker::Lorem.word
# 			)
# 		rescue => e
# 			e.message
# 		end
# 	end
# 	puts "Tags created #{Tag.all.count}"
# end

# seeder.create_if_none(Article) do
# 	category = Category.all.pluck(:name)
# 	tag = Tag.all
# 	user = User.all.pluck(:id)
# 	100.times do
# 		begin
# 			Article.create!(
# 				title: Faker::Lorem.sentence.downcase,
# 				description: Faker::Lorem.paragraphs.join("\n\n"),
# 				category: category.sample,
# 				user_id: user.sample,
# 				publish: [true,false].sample,
# 				tags: tag.sample
# 			)
# 		rescue => e
# 			puts e.message
# 		end
# 	end
# 	puts "Article created #{Article.all.count}"
# end