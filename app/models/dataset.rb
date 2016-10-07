# frozen_string_literal: true
# == Schema Information
#
# Table name: datasets
#
#  id           :uuid             not null, primary key
#  data_columns :jsonb
#  data_horizon :integer          default(0)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Dataset < ApplicationRecord
  def self.notifier(object_id, status=nil)
    DatasetServiceJob.perform_later(object_id, status)
  end
end
