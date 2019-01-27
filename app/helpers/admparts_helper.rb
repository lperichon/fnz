module AdmpartsHelper

  def pm(number)
    number_with_precision number, precision: 2
  end

  def link_to_tag_detail(tag)
    link_to tag.name, business_transactions_path(business_id: @adm.business_id,
                                                 admpart_tag_id: tag.id,
                                                 report_on: @adm.ref_date
                                                )
  end

  def ref_date_options
    options = []
    (0..6).each do |i|
      i=6-i
      options << [l(i.month.ago.to_date.beginning_of_month, format: :month),
                  i.month.ago.to_date.beginning_of_month]
    end
    options_for_select( options, @adm.ref_date )
  end
end
