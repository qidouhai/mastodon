# frozen_string_literal: true

class ActivityPub::Activity::Flag < ActivityPub::Activity
  def perform
    target_accounts            = object_uris.map { |uri| account_from_uri(uri) }.compact.select(&:local?)
    target_statuses_by_account = object_uris.map { |uri| status_from_uri(uri) }.compact.select(&:local?).group_by(&:account_id)

    target_accounts.each do |target_account|
      next if Report.where(account: @account, target_account: target_account).exists?

      target_statuses = target_statuses_by_account[target_account.id]

      ReportService.new.call(
        @account,
        target_account,
        status_ids: target_statuses.nil? ? [] : target_statuses.map(&:id),
        comment: @json['content'] || '',
        pawoo_report_type: 'other'
      )
    end
  end

  def object_uris
    @object_uris ||= Array(@object.is_a?(Array) ? @object.map { |item| value_or_id(item) } : value_or_id(@object))
  end
end
