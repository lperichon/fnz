module ReceiptsHelper

  def public_receipt_url(receipt)
    if Rails.env.production?
      receipt_url(id: receipt.id, secret: receipt.url_secret, host: "receipts.derose.app")
    else
      receipt_url(id: receipt.id, secret: receipt.url_secret)
    end
  end
end
