module AdmpartsHelper

  def pm(number)
    content_tag :span, class: "admpart-value #{number_css_class(number)}" do
      number_to_currency number
    end
  end

  def number_css_class(n)
    return if n == 0
    (n>0)? 'positive' : 'negative'
  end

  def link_to_tag_detail(tag)
    link_to tag.name, business_transactions_path(business_id: @adm.business_id,
                                                 admpart_tag_id: tag.id,
                                                 report_on: @adm.ref_date
                                                )
  end

  def link_to_not_tagged(msg)
    link_to msg, business_transactions_path(business_id: @adm.business_id,
                                            q: { admpart_tag_id: "" },
                                            report_on: @adm.ref_date)
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
