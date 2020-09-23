module Api
  module ParametersService
    extend self

    ##########################################
    # Create a relationship hash for tags array for backwards compatibility
    #
    def create_tags_relationship(tags, user)
      tag_records = tags.map { |tag| Tag.find_or_create_by(name: tag, user: user) }
      json        = tag_records.map { |tag| { type: "tags", id: tag.id } }

      {
        "tags": {
          "data": json
        }
      }
    end
  end
end