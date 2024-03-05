# functions used to detect test pass/fail.  Mostly useful shorthand.
#returns count of 'tags' contents
def count(document)
  xml = doc_xml(document)
  count = xml.xpath("//content[@name='tags']").length
  return count
end

# returns the modified-by attribute of first 'tags' content
def user(document)
  xml = doc_xml(document)
  user = xml.xpath("//content[@name='tags']/@modified-by").to_s
  return user
end

# returns the text value of first 'tags' conten
def tag(document)
  xml = doc_xml(document)
  tag = xml.xpath("//content[@name='tags']").text
  return tag
end

# given an xpath to a content, returns its content-id attribute.
def content_id(document, content_xpath)
  xml = doc_xml(document)
  id_xpath = content_xpath + "/@content-id"
  id = xml.xpath(id_xpath).to_s
  return id
end

# returns an xml version of the VXML of a document, to be used with .elements.  All of the above functions use this function.
def doc_xml(document)
  return document.get_xml
end