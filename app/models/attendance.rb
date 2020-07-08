class Attendance < ApplicationRecord
  belongs_to :user
  has_many :logs, dependent: :destroy
  
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  
  # 出社時間が存在しない場合、退社時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  
  # 退社時間の登録には、出社時間が必要
  validate :finished_at_needs_a_started_at
  
  # 出社・退社時間どちらも存在する時、出社時間より早い退社時間は無効
  validate :started_at_than_finished_at_fast_if_invalid
  
  # 退社時間登録には、出社時間より遅い時間である必要
  validate :finished_at_is_after_started_at
  
  #1ヶ月承認モーダルの変更確認チェックボックス
  validates_acceptance_of :must
  
# 勤怠変更申請
  # 変更出社時間が存在しない場合、変更退社時間は無効
  validate :t_finished_at_is_invalid_without_a_t_started_at

  # 変更退社時間の登録には、変更出社時間が必要
  validate :t_finished_at_needs_a_t_started_at
  
  # 変更出社・変更退社時間どちらも存在する時、変更出社時間より早い変更退社時間は無効
  validate :t_started_at_than_t_finished_at_fast_if_invalid
  
  # 変更退社時間登録には、変更出社時間より遅い時間である必要
  validate :t_finished_at_is_after_t_started_at
  
  
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が未入力です") if started_at.blank? && finished_at.present?
  end
  
  def finished_at_needs_a_started_at
    errors.add(:finished_at, "の登録には、出社時間の登録が必要です") if started_at.blank? && finished_at.present?
  end
  
  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "の入力間違いの可能性があります") if started_at > finished_at
    end
  end
  
  def finished_at_is_after_started_at
    if started_at.present? && finished_at.present?
      errors.add(:finished_at, "より遅い出社時間は無効です") if started_at > finished_at
    end
  end
  
  # 勤怠変更申請
  def t_finished_at_is_invalid_without_a_t_started_at
    errors.add(:t_started_at, "が未入力です") if t_started_at.blank? && t_finished_at.present?
  end
  
  def t_finished_at_needs_a_t_started_at
    errors.add(:t_finished_at, "の登録には、変更出社時間の登録が必要です") if t_started_at.blank? && t_finished_at.present?
  end
  
  def t_started_at_than_t_finished_at_fast_if_invalid
    if t_started_at.present? && t_finished_at.present?
      errors.add(:t_started_at, "の入力間違いの可能性があります") if t_started_at > t_finished_at
    end
  end
  
  def t_finished_at_is_after_t_started_at
    if t_started_at.present? && t_finished_at.present?
      errors.add(:t_finished_at, "より遅い出社時間は無効です") if t_started_at > t_finished_at
    end
  end
  
  #1ヶ月の勤怠情報の申請ステータス
  enum month_approval: { "未申請": 0, "申請中": 1, "承認": 2, "否認": 3}
  
  #勤怠変更申請の申請ステータス
  enum edit_approval: { "未申請": 0, "申請中": 1, "承認": 2, "否認": 3}, _prefix: true
  
  #残業申請の申請ステータス
  enum overtime_approval: { "未申請": 0, "申請中": 1, "承認": 2, "否認": 3}, _prefix: true
  
end
