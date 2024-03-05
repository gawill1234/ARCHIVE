class TestResults
  EXPECTED_ATTRIBUTES = ['vse-doc-hash', 'stub'].freeze

  def test_stub_document(doc)
    add_number_equals(EXPECTED_ATTRIBUTES.count, doc.attributes.count, 'document attribute')

    EXPECTED_ATTRIBUTES.each do |expected_attribute|
      add(doc.attributes.include?(expected_attribute),
          "has attribute #{expected_attribute}",
          "does not have attribute #{expected_attribute}")
    end
  end
end
