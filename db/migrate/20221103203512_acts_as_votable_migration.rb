class ActsAsVotableMigration < ActiveRecord::Migration[7.0]
  def self.up
    create_table :votos do |t|

      t.references :votable, :polymorphic => true
      t.references :voter, :polymorphic => true

      t.boolean :vote_flag
      t.string :vote_scope
      t.integer :vote_weight

      t.timestamps
    end

    if ActiveRecord::VERSION::MAJOR < 4
      add_index :votos, [:votable_id, :votable_type]
      add_index :votos, [:voter_id, :voter_type]
    end

    add_index :votos, [:voter_id, :voter_type, :vote_scope]
    add_index :votos, [:votable_id, :votable_type, :vote_scope]
  end

  def self.down
    drop_table :votos
  end
end
