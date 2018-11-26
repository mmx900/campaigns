class AddDraftToCampaigns < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        transaction do
          add_column :campaigns, :draft, :boolean, default: true
          Campaign.update_all "draft = false"
        end
      end
      dir.down do
        transaction do
          remove_column :campaigns, :draft
        end
      end
    end
  end

end
