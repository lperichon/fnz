module ReceiptsHelper

  def public_receipt_url(receipt)
    if Rails.env.production?
      "https://receipts.derose.app/r/#{receipt.id}?s=#{receipt.url_secret}"
    else
      receipt_url(id: receipt.id, s: receipt.url_secret)
    end
  end

  def whatsapp_url(receipt)
    text = %[#{t(".receipt")}##{@receipt.id}: #{number_to_currency(@receipt.amount, unit: @receipt.currency.symbol)}\n#{public_receipt_url(receipt)}]
    "https://api.whatsapp.com/send?text=#{URI.encode(text)}"
  end
end
