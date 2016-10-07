class Mark < ActiveRecord::Base
  has_many :visits,  dependent: :destroy
  has_one :stat,  dependent: :destroy

  private

  def self.gen_hashid(tag)
    # TODO: Configuration
    hashidsalt='this is my random long string for initialization of Hashids'
    hashidlength=8
    hashidkeyspace='ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    hashids = Hashids.new(hashidsalt, hashidlength, hashidkeyspace)
    hashids.encode(tag)
  end

  def to_param  # overridden
    hashid
  end

  def self.from_param(param)
    self.find_by_hashid!(param)
  end
end
