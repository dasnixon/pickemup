module JobListingsHelper
  def salary_range
    developer = (10000..200000).step(10000).to_a
    manager = (225000..350000).step(25000).to_a
    range = (developer + manager).map { |salary| salary.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse.prepend("$") }
    range.map! { |salary| [salary, salary.gsub(/\D/,"").to_i] }
    range.insert(0,["Less than $10,000", 0])
    range << ["More than $350,000", 500000]
  end

  def conversation_user(conversation)
    participants = conversation.participants
    participants.last.class.name == "User" ? participants.last : participants.first
  end
end
