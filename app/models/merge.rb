class Merge 
  attr_accessor :son_id, :father_id

  def initialize(son_id, father_id)
    self.son_id = son_id
    self.father_id = father_id
  end

  def merge
    Contact.where(padma_id: son_id).each do |son|
      father = son.business.contacts.where(padma_id: father_id).first
      if father
        Membership.where(contact_id: son.id).update_all(contact_id: father.id)
        Sale.where(contact_id: son.id).update_all(contact_id: father.id)
        # TODO recalculate current memebership
        son.destroy
      else
        son.update_attributes(padma_id: father_id)
      end
    end
  end
end
