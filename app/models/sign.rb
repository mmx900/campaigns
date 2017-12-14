class Sign < ApplicationRecord
  include Reportable

  belongs_to :user, optional: true
  belongs_to :petition, counter_cache: true

  validates :user, uniqueness: { scope: :petition }, if: 'user.present?'
  validate :valid_signer
  validates :signer_email, format: { with: Devise.email_regexp }, uniqueness: { scope: :petition }, if: 'signer_email.present?'

  scope :recent, -> { order(created_at: :desc) }
  scope :earlier, -> { order(created_at: :asc) }

  def user_image_url
    user.present? ? user.image.sm.url : ActionController::Base.helpers.asset_path('default-user.png')
  end

  def user_name
    signer_real_name.presence || (user.present? ? user.nickname : signer_name)
  end

  def user_email
    user.present? ? user.email : signer_email
  end

  private

  def valid_signer
    if petition.use_signer_real_name?
      if signer_real_name.blank?
        errors.add(:signer_name, I18n.t('errors.messages.blank'))
      end
    else
      if user.blank? and signer_name.blank?
        errors.add(:signer_name, I18n.t('errors.messages.blank'))
      end
    end

    if petition.use_signer_email? and signer_email.blank?
      errors.add(:signer_name, I18n.t('errors.messages.blank'))
    end

    if petition.use_signer_address? and signer_address.blank?
      errors.add(:signer_name, I18n.t('errors.messages.blank'))
    end
  end
end
