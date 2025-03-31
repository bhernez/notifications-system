class CommandBase
  attr_accessor :form

  def self.call(**args)
    new.tap { const_defined?(:Form, false) && (_1.form = const_get(:Form)&.new(**args)) }.call
  end

  private

  def validate
    # This could be a set of validations to ensure that the data is correct
    form.nil? ? true : form.validate!
  end
end
