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
end
