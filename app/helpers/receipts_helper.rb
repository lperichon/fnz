module ReceiptsHelper

  def public_receipt_url(receipt)
    if Rails.env.production?
      "https://receipts.derose.app/#{receipt.id}?secret=#{receipt.url_secret}"
    else
      receipt_url(id: receipt.id, secret: receipt.url_secret)
    end
  end
end
