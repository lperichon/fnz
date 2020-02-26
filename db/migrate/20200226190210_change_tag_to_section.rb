class ChangeTagToSection < ActiveRecord::Migration
  def change
    add_column :custom_prizes, :admpart_section, :string

    CustomPrize.joins(:tag).where(tags: { system_name: "enrollment" }).update_all(admpart_section: "enrollment")
    CustomPrize.joins(:tag).where(tags: { system_name: "sale" }).update_all(admpart_section: "sale")

    remove_column :custom_prizes, :tag_id
  end
end
