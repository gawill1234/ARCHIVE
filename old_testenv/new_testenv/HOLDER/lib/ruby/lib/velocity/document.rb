module Velocity
  class Document
    attr_reader :vse_key

    def initialize(vapi, options = {})  # this allows to specify any of the arguments in any order
      @vapi = vapi
      @vse_key = options[:vse_key]
      @collection = options[:collection] || 'example-metadata'
      @user = options[:user] || 'test-all'
    end

    def get_xml()
      @vapi.query_search({ :query => 'DOCUMENT_KEY: ' + @vse_key,
                           :sources => @collection })
    end

    # basic tagging
    def add_annotation(content, user=@user, acl='" "')
      @vapi.annotation_add({ :collection => @collection,
                             :document_vse_key => @vse_key,
                             :content => content,
                             :username => user,
                             :acl => acl })
    end

    def delete_annotation(name, id, user=@user)
      @vapi.annotation_delete({ :collection => @collection,
                                :document_vse_key => @vse_key,
                                :content_name => name,
                                :content_id => id,
                                :username => user })
    end

    # user tagging
    def add_one_annotation_per_user(content, user=@user, acl='" "')
      @vapi.annotation_user_set({ :collection => @collection,
                                  :document_vse_key => @vse_key,
                                  :content => content,
                                  :username => user,
                                  :acl => acl })
    end

    # global tagging
    def add_one_annotation_per_doc(content, user=@user, acl='" "')
      @vapi.annotation_global_set({ :collection => @collection,
                                    :document_vse_key => @vse_key,
                                    :content => content,
                                    :username => user,
                                    :acl => acl })
    end

    def update_annotation(content, id, user=@user, acl='" "')
      @vapi.annotation_update({ :collection => @collection,
                                :document_vse_key => @vse_key,
                                :content => content,
                                :content_id => id,
                                :username => user,
                                :acl => acl })
    end

    ## Express tagging API functions ####
    # !!!!!!!!!!!!!!!
    # it might make more sense to move these outside the Doc class, since this apply to a list of documents not just one doc...

    def add_annotation_to_multiple_docs(content,
                                        documents,
                                        user=@user,
                                        acl='" "')
      @vapi.annotation_express_add_doc_list({ :collection => @collection,
                                              :content => content,
                                              :documents => documents,
                                              :username => user,
                                              :acl => acl })
    end

    def annotation_express_update_doc_list(content,
                                           content_old,
                                           documents,
                                           user=@user,
                                           acl='" "')
      @vapi.annotation_express_update_doc_list({ :collection => @collection,
                                                 :content => content,
                                                 :content_old => content_old,
                                                 :documents => documents,
                                                 :username => user,
                                                 :acl => acl })
    end

    def annotation_express_update_query(content,
                                        content_old,
                                        query,
                                        user=@user,
                                        acl='" "')
      @vapi.annotation_express_update_query({ :collection => @collection,
                                              :content => content,
                                              :content_old => content_old,
                                              :query => query,
                                              :username => user,
                                              :acl => acl })
    end

    def delete_annotation_from_multiple_docs(content,
                                             documents,
                                             user=@user)
      @vapi.annotation_express_delete_doc_list({ :collection => @collection,
                                                 :content => content,
                                                 :documents => documents,
                                                 :username => user })
    end

    def add_annotation_for_query(content,
                                 query,
                                 user=@user,
                                 acl='" "')
      @vapi.annotation_express_add_query({ :collection => @collection,
                                           :content => content,
                                           :query => query,
                                           :username => user,
                                           :acl => acl })
    end

    def delete_annotation_for_query(content,
                                    query,
                                    user=@user)
      @vapi.annotation_express_delete_query({ :collection => @collection,
                                              :content => content,
                                              :query => query,
                                              :username => user })
    end

    def add_one_annotation_per_doc_to_multiple_docs(content,
                                                    documents,
                                                    user=@user,
                                                    acl='" "')
      @vapi.annotation_express_global_set_doc_list({ :collection => @collection,
                                                     :content => content,
                                                     :documents => documents,
                                                     :username => user,
                                                     :acl => acl })
    end

    def add_one_annotation_per_doc_to_query(content,
                                            query,
                                            user=@user,
                                            acl='" "',
                                            num_docs="200")
      @vapi.annotation_express_global_set_query({ :collection => @collection,
                                                  :content => content,
                                                  :query => query,
                                                  :num_docs_at_a_time => num_docs,
                                                  :username => user,
                                                  :acl => acl })
    end

    def add_one_annotation_per_user_to_multiple_docs(content,
                                                     documents,
                                                     user=@user,
                                                     acl='" "')
      @vapi.annotation_express_user_set_doc_list({ :collection => @collection,
                                                   :content => content,
                                                   :documents => documents,
                                                   :username => user,
                                                   :acl => acl })
    end

    def add_one_annotation_per_user_to_query(content,
                                             query,
                                             user=@user,
                                             acl='" "',
                                             num_docs="200")
      @vapi.annotation_express_user_set_query({ :collection => @collection,
                                                :content => content,
                                                :query => query,
                                                :num_docs_at_a_time => num_docs,
                                                :username => user,
                                                :acl => acl })
    end

    #These are internal API functions that we are not supposed to test directly:
    # annotation-permissions

  end
end