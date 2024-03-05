#!/usr/bin/python

import xmlrpclib
import zipfile
import sys
import os
import mimetypes

class CONFLUENCE:

    __module__ = __name__

    __server = None
    __token = None
    __myMime = None
    __parentId = None
    __verbose = False
    __debug = False

    def __init__(self, server_url, user = 'admin', pw = 'Baseball123'):

        self.__server = xmlrpclib.ServerProxy(server_url)
        self.__token = self.__server.confluence2.login(user, pw)
        self.__myMime = mimetypes.MimeTypes()

        return

    #
    #   Support routine.  Probably should be in a helper class.
    #
    def readTheFile(self, filename):
        data = None
        if (filename is not None):
            try:
                f = open(filename, 'rb')
            except:
                print 'Error function  :  readTheFile()'
                print 'Error file name : ',
                print filename
                print 'Python I/O error: ',
                print sys.exc_info()
                return
            data = f.read()
            f.close()
        return data



    #
    #   Support routine.  Probably should be in a helper class.
    #   This one is different in that it will properly extract
    #   the data from a newer office file (docx, ppts, xlsx).
    #   So far, works for word.  Needs a couple of tweaks for
    #   powerpoint and excel.
    #
    def readTheFile2(self, filename):
        data = None
        if (filename is not None):
            flist = filename.split('.')
            if (flist[(len(flist) - 1)].lower() in ['docx',
             'pptx',
             'xlsx']):
                print filename
                z = zipfile.ZipFile(filename, 'rb')
                data = z.read('word/document.xml')
            else:
                try:
                    f = open(filename, 'rb')
                except:
                    print 'Error function  :  readTheFile()'
                    print 'Error file name : ',
                    print filename
                    print 'Python I/O error: ',
                    print sys.exc_info()
                    return
                data = f.read()
                f.close()
        return data


    #
    #   Useful only if the Mimetype stuff isn't giving the
    #   answers you want.
    #
    def getFileType(self, path):

        if path.endswith('.html'):
            return 'text/html'
        if path.endswith('.xml'):
            return 'text/xml'
        if path.endswith('.vxml'):
            return 'application/vxml-unnormalized'
        if path.endswith('.xls'):
            return 'application/ms-ooxml-excel'
        if path.endswith('.doc'):
            return 'application/ms-ooxml-word'
        if path.endswith('.pdf'):
            return 'application/pdf'
        return 'text/plain'


    #
    #   Turn verbose mode on
    #
    def set_verbose(self, TorF = False):

        self.__verbose = TorF
        return


    #
    #   Turn debug mode on
    #
    def set_debug(self, TorF = False):

        self.__debug = TorF
        return


    #
    #   Check if a confluence user exists.
    #
    def userExists(self, userName):

        if ( self.__server.confluence2.hasUser(self.__token, userName) ):
            return True

        return False


    def setParentId(self, parentId = None):
        self.__parentId = parentId


    def unsetParentId(self):
        self.__parentId = None

    ###################################################################
    #
    #   Permissions stuff.  For Confluence, persmissions are only on spaces and pages
    #   Where "perm" or "permission" is an argument, it can be one of the following:
    #   "view", "modify", "comment" and / or "admin"
    #
    def getUserSpacePermissions(self, spaceKey=None, userName=None):

        if ( spaceKey is not None and userName is not None ):
            try:
                permList = self.__server.confluence2.getPermissionsForUser(self.__token,
                                                                           spaceKey, userName)
            except:
                if self.__verbose:
                    print 'Error function:  getUserSpacePermissions'
                    print 'Error Confluence function:  confluence2.getPermissionsForUser()'
                    print 'Confluence error: ',
                    print sys.exc_info()
                permList = []
        else:
           permList = []

        return permList

    def getSpacePermissions(self, spaceKey=None):

        if ( spaceKey is not None ):
            try:
                permList = self.__server.confluence2.getPermissions(self.__token, spaceKey)
            except:
                if self.__verbose:
                    print 'Error function:  getSpacePermissions'
                    print 'Error Confluence function:  confluence2.getPermissions()'
                    print 'Confluence error: ',
                    print sys.exc_info()
                permList = []
        else:
           permList = []

        return permList

    def removeSpacePermission(self, spaceKey=None, userOrGroupName=None, perm=None):

        if ( spaceKey is not None and perm is not None and
             userOrGroupName is not None ):
            try:
                didIt = self.__server.confluence2.removePermissionFromSpace(self.__token,
                                                                          perm,
                                                                          userOrGroupName,
                                                                          spaceKey)
            except:
                if self.__verbose:
                    print 'Error function:  removeSpacePermissions'
                    print 'Error Confluence function:  confluence2.removePermissionFromSpace()'
                    print 'Confluence error: ',
                    print sys.exc_info()
                didIt = False
        else:
           didIt = False

        return didIt

    def addSpacePermission(self, spaceKey=None, userOrGroupName=None, perm=None):

        if ( spaceKey is not None and perm is not None and
             userOrGroupName is not None ):
            try:
                didIt = self.__server.confluence2.addPermissionToSpace(self.__token,
                                                                          perm,
                                                                          userOrGroupName,
                                                                          spaceKey)
            except:
                if self.__verbose:
                    print 'Error function:  addSpacePermissions'
                    print 'Error Confluence function:  confluence2.addPermissionToSpace()'
                    print 'Confluence error: ',
                    print sys.exc_info()
                didIt = False
        else:
           didIt = False

        return didIt

    def removeAllGroupPermissions(self, groupName=None):

        if ( groupName is not None ):
            try:
                didIt = self.__server.confluence2.removeAllPermissionsForGroup(self.__token,
                                                                               groupName)
            except:
                if self.__verbose:
                    print 'Error function:  removeAllGroupPermissions'
                    print 'Error Confluence function:  confluence2.removeAllPermissionsForGroup()'
                    print 'Confluence error: ',
                    print sys.exc_info()
                didIt = False
        else:
           didIt = False

        return didIt



    def removeAnonymousSpacePermission(self, spaceKey=None, perm=None):

        if ( spaceKey is not None and perm is not None ):
            try:
                didIt = self.__server.confluence2.removeAnonymousPermissionFromSpace(self.__token,
                                                                                     perm,
                                                                                     spaceKey)
            except:
                if self.__verbose:
                    print 'Error function:  removeAnonymousSpacePermissions'
                    print 'Error Confluence function:  confluence2.removeAnonymousPermissionFromSpace()'
                    print 'Confluence error: ',
                    print sys.exc_info()
                didIt = False
        else:
           didIt = False

        return didIt


    def addAnonymousSpacePermission(self, spaceKey=None, userOrGroupName=None, perm=None):

        if ( spaceKey is not None and perm is not None ):
            try:
                didIt = self.__server.confluence2.addAnonymousPermissionToSpace(self.__token,
                                                                          perm,
                                                                          spaceKey)
            except:
                if self.__verbose:
                    print 'Error function:  addAnonymousSpacePermissions'
                    print 'Error Confluence function:  confluence2.addAnonymousPermissionToSpace()'
                    print 'Confluence error: ',
                    print sys.exc_info()
                didIt = False
        else:
           didIt = False

        return didIt


    def getAvailablePermissions(self):

        try:
            permList = self.__server.confluence2.getSpaceLevelPermissions(self.__token)
        except:
            if self.__verbose:
                print 'Error function:  getSpacePermissions'
                print 'Error Confluence function:  confluence2.getPermissions()'
                print 'Confluence error: ',
                print sys.exc_info()
            permList = []

        return permList

    def getPagePermissions(self, pageId=None, spaceKey=None, pageTitle=None):

        if ( pageId is None ):
            if ( spaceKey is not None and pageTitle is not None ):
                myPage = self.getPage(spaceKey, pageTitle)
                pageId = myPage['id']

        if ( pageId is not None ):
            try:
                permList = self.__server.confluence2.getPagePermissions(self.__token, pageId)
            except:
                if self.__verbose:
                    print 'Error function:  getPagePermissions'
                    print 'Error Confluence function:  confluence2.getPagePermissions()'
                    print 'Confluence error: ',
                    print sys.exc_info()
                permList = []
        else:
           permList = []

        return permList

    def getContentPermissions(self, pageId=None, spaceKey=None, pageTitle=None):

        if ( pageId is None ):
            if ( spaceKey is not None and pageTitle is not None ):
                myPage = self.getPage(spaceKey, pageTitle)
                pageId = myPage['id']

        if ( pageId is not None ):
            try:
                permList = self.__server.confluence2.getContentPermissionSets(self.__token, pageId)
            except:
                if self.__verbose:
                    print 'Error function:  getContentPermissions'
                    print 'Error Confluence function:  confluence2.getContentPermissionSets()'
                    print 'Confluence error: ',
                    print sys.exc_info()
                permList = []
        else:
           permList = []

        return permList

    def getContentPermissionSet(self, pageId=None, spaceKey=None, pageTitle=None, perm=None):

        if ( pageId is None ):
            if ( spaceKey is not None and pageTitle is not None ):
                myPage = self.getPage(spaceKey, pageTitle)
                pageId = myPage['id']

        if ( pageId is not None and perm is not None ):
            try:
                permList = self.__server.confluence2.getContentPermissionSet(self.__token,
                                                                             pageId,
                                                                             perm)
            except:
                if self.__verbose:
                    print 'Error function:  getContentPermissionSet'
                    print 'Error Confluence function:  confluence2.getContentPermissionSet()'
                    print 'Confluence error: ',
                    print sys.exc_info()
                permList = []
        else:
           permList = []

        return permList

    def setContentPermissions(self, pageId=None, spaceKey=None, pageTitle=None,
                                    perm=None, allPerms=None):

        if ( pageId is None ):
            if ( spaceKey is not None and pageTitle is not None ):
                myPage = self.getPage(spaceKey, pageTitle)
                pageId = myPage['id']

        if ( pageId is not None and perm is not None ):
            try:
                permList = self.__server.confluence2.setContentPermissions(self.__token,
                                                                           pageId,
                                                                           perm,
                                                                           allPerms)
            except:
                if self.__verbose:
                    print 'Error function:  setContentPermissions'
                    print 'Error Confluence function:  confluence2.setContentPermissions()'
                    print 'Confluence error: ',
                    print sys.exc_info()
                permList = []
        else:
           permList = []

        return permList

    #
    #   End permission stuff
    #
    #######################################################

    def buildUser(self, userName):

       myUser = {}
       myUser['name'] = userName
       myUser['fullname'] = userName
       myUser['email'] = userName + '@vivisimo.com'
       myUser['url'] = 'http://172.16.10.81:8090/display/-' + userName

       return myUser



    #
    #   Add a new confluence user
    #
    def newUser(self, userName=None, pw=None, failIfExists=False):

        if ((userName is None) or (pw is None)):
            print 'Error:  User name or password for new user not specified'
            return False

        if self.userExists(userName):
            print 'Error?: Requested user name already exists'
            if failIfExists:
                return False
            return True
        else:
            try:
                myUser = self.buildUser(userName)
                self.__server.confluence2.addUser(self.__token, myUser, pw)
            except:
                if self.__verbose:
                    print 'Error function:  newUser'
                    print 'Error Confluence function:  confluence2.addUser()'
                    print 'User Name =', userName, 'Password =', pw
                    print 'Confluence error: ', sys.exc_info()
                return False

        return True


    #
    #   Remove the named confluence user from the named group.
    #   If the user was never in the group, the method still returns True
    #
    def removeUserFromGroup(self, userName, groupName):

        groupList = self.getUsersGroups(userName)
        for item in groupList:
            if (item == groupName):
                try:
                    self.__server.confluence2.removeUserFromGroup(self.__token, userName, groupName)
                except:
                    if self.__verbose:
                        print 'Error function:  removeUserFromGroup'
                        print 'Error Confluence function:  confluence2.removeUserFromGroup()'
                        print 'Confluence error: ',
                        print sys.exc_info()
                    return False

        return True



    #
    #   Add the named confluence user to the named group
    #
    def addUserToGroup(self, userName, groupName):

        print 'Action:  Add user',
        print userName,
        print 'to group',
        print groupName

        if self.userExists(userName):

            if self.groupExists(groupName):

                try:
                    groupList = self.__server.confluence2.addUserToGroup(self.__token, userName, groupName)
                except:
                    if self.__verbose:
                        print 'Error function:  addUserToGroup'
                        print 'Error Confluence function:  confluence2.addUserToGroup()'
                        print 'Confluence error: ',
                        print sys.exc_info()
                    return False

                return True

        print 'Error:   user name or group name does not exist'
        return False


    #
    #   Get a list of all the groups a confluence user is in
    #
    def getUsersGroups(self, userName):

        try:
            groupList = self.__server.confluence2.getUserGroups(self.__token, userName)
        except:
            if self.__verbose:
                print 'Error function:  getUsersGroups'
                print 'Error Confluence function:  confluence2.getUserGroups()'
                print 'Confluence error: ',
                print sys.exc_info()
            groupList = []

        return groupList



    #
    #   Get the user properties for the named confluence user
    #
    def getUserInfo(self, userName):

        try:
            userData = self.__server.confluence2.getUser(self.__token, userName)
        except:
            if self.__verbose:
                print 'Error function:  getUserInfo'
                print 'Error Confluence function:  confluence2.getUser()'
                print 'Confluence error: ',
                print sys.exc_info()
            userData = {}

        return userData



    #
    #  Deactivate a user.  Deactive does not delete the user,
    #  just makes the user id inactive.
    #
    def deactivateUser(self, userName):

        try:
            self.__server.confluence2.deactivateUser(self.__token, userName)
        except:
            if self.__verbose:
                print 'Error function:  deactivateUser'
                print 'Error Confluence function:  confluence2.deactivateUser()'
                print 'Confluence error: ',
                print sys.exc_info()
            return False

        return True



    #
    #   Reactivate a previously deactivated confluence user
    #
    def reactivateUser(self, userName):

        try:
            self.__server.confluence2.reactivateUser(self.__token, userName)
        except:
            if self.__verbose:
                print 'Error function:  reactivateUser'
                print 'Error Confluence function:  confluence2.reactivateUser()'
                print 'Confluence error: ',
                print sys.exc_info()
            return False

        return True



    #
    #   List every active confluence user
    #
    def listAllUsers(self):

        try:
            userList = self.__server.confluence2.getActiveUsers(self.__token, False)
        except:
            if self.__verbose:
                print 'Error function:  listAllUsers'
                print 'Error Confluence function:  confluence2.getActiveUsers()'
                print 'Confluence error: ',
                print sys.exc_info()
            userList = []

        return userList



    #
    #   Make the confluence user go away.
    #
    def deleteUser(self, userName = None):

        if self.userExists(userName):
            try:
                self.__server.confluence2.removeUser(self.__token, userName)
            except:
                if self.__verbose:
                    print 'Error function:  deleteGroup'
                    print 'Error Confluence function:  confluence2.removeGroup()'
                    print 'Confluence error: ',
                    print sys.exc_info()
                return False

        return True


    #
    #   See if a group exists.
    #
    def groupExists(self, groupName):

        try:
           if self.__server.confluence2.hasGroup(self.__token, groupName):
               return True
        except:
            if self.__verbose:
                print 'Error function:  groupExists'
                print 'Error Confluence function:  confluence2.hasGroup()'
                print 'Confluence error: ',
                print sys.exc_info()

        return False



    #
    #   Add a group.  Returns True if the group was
    #   successfully added OR if it already exists.
    #
    def newGroup(self, groupName):

        if self.groupExists(groupName):
            return True
        else:
            try:
                self.__server.confluence2.addGroup(self.__token, groupName)
            except:
                if self.__verbose:
                    print 'Error function:  newGroup'
                    print 'Error Confluence function:  confluence2.addGroup()'
                    print 'Confluence error: ',
                    print sys.exc_info()
                return False

        return True



    #
    #   List all the confluence groups.
    #
    def listAllGroups(self):

        try:
            groupList = self.__server.confluence2.getGroups(self.__token)
        except:
            print 'Error function:  listAllGroups'
            print 'Error Confluence function:  confluence2.getGroups()'
            print 'Confluence error: ',
            print sys.exc_info()
            groupList = []

        return groupList



    #
    #   Delete a group.  If it was successfully deleted or if it
    #   does not exist, return True
    #
    def deleteGroup(self, groupName = None, defaultGroup = None):

        if self.groupExists(groupName):
            try:
                self.__server.confluence2.removeGroup(self.__token, groupName, defaultGroup)
            except:
                print 'Error function:  deleteGroup'
                print 'Error Confluence function:  confluence2.removeGroup()'
                print 'Confluence error: ',
                print sys.exc_info()
                return False

        return True



    def addPersonalSpace(self, cSpace, userName):

        if self.spaceExists(spaceKey=cSpace['key']):
            result = self.getSpace(cSpace['key'])
        else:
            try:
                result = self.__server.confluence2.addPersonalSpace(self.__token, cSpace, userName)
            except:
                print 'Error function:  addNewSpace'
                print 'Error Confluence function:  confluence2.addSpace()'
                print 'Confluence error: ',
                print sys.exc_info()
                result = {}

        return result



    def createPersonalSpace(self, spaceKey, spaceName, spaceDesc, userName):

        cSpace = self.initializeSpace(spaceKey, spaceName, spaceDesc)
        err = self.addPersonalSpace(cSpace, userName)

        return err



    #
    #   Obliterate deleted items.
    #
    def clearAllTrash(self, spaceKey):

        try:
            self.__server.confluence2.emptyTrash(self.__token, spaceKey)
        except:
            return

        return


    def setSpaceStatus(self, spaceKey, status = 'CURRENT'):

        try:
            self.__server.confluence2.setSpaceStatus(self.__token, spaceKey, status)
        except:
            return

        return



    #
    #   Stub
    #
    def spaceExists(self, spaceKey = None):

        try:
           cSpace = self.__server.confluence2.getSpace(self.__token, spaceKey)
        except:
           cSpace = {}
           return False

        if ( cSpace is not None and cSpace != {} ):
           if ( cSpace['key'] == spaceKey ):
              return True

        return False



    def initializeSpace(self, spaceKey, spaceName, spaceDesc):

        cSpace = {}
        cSpace['key'] = spaceKey
        cSpace['name'] = spaceName
        cSpace['description'] = spaceDesc
        return cSpace



    #
    #   Create a new space.  If the space exists, update the properties.
    #   If it does not, create it.
    #
    def addNewSpace(self, cSpace = {}):

        if ( cSpace == {} or cSpace is None ):
           return {}

        if self.spaceExists(spaceKey=cSpace['key']):

            try:
                result = self.__server.confluence2.storeSpace(self.__token, cSpace)
            except:
                print 'Error function:  addNewSpace'
                print 'Error Confluence function:  confluence2.storeSpace()'
                print 'Confluence error: ', sys.exc_info()
                result = {}

        else:

            try:
                result = self.__server.confluence2.addSpace(self.__token, cSpace)
            except:
                print 'Error function:  addNewSpace'
                print 'Error Confluence function:  confluence2.addSpace()'
                print 'Confluence error: ', sys.exc_info()
                result = {}

        return result



    #
    #   Delete a space.
    #
    def deleteSpace(self, spaceKey):

        if self.spaceExists(spaceKey):
            try:
                result = self.__server.confluence2.removeSpace(self.__token, spaceKey)
            except:
                print 'Error function:  deleteSpace'
                print 'Error Confluence function:  confluence2.removeSpace()'
                print 'Confluence error: ', sys.exc_info()
                result = False
        else:
            result = True

        return result



    #
    #   Do everything needed to create a space.  Create the space
    #   dictionary and then use it to create the space.
    #
    def createSpace(self, spaceKey, spaceName, spaceDesc):

        cSpace = self.initializeSpace(spaceKey, spaceName, spaceDesc)
        err = self.addNewSpace(cSpace)

        return err



    #
    #   Get a list of all spaces.
    #
    def getAllSpaces(self):

        spaceList = self.__server.confluence2.getSpaces(self.__token)

        return spaceList



    #
    #   Get a list of all pages on the named space.
    #
    def getSpacePages(self, spaceKey = None):

        pageList = self.__server.confluence2.getPages(self.__token, spaceKey)

        return pageList



    #
    #   Get the properties of the named space.
    #
    def getSpace(self, spaceKey = None):

        try:
            spaceData = self.__server.confluence2.getSpace(self.__token, spaceKey)
        except:
            spaceData = {}

        return spaceData



    #
    #  Print a list of all the pages on a space.
    #
    def listSpacePages(self, spaceKey = None):

        pageList = self.getSpacePages(spaceKey)

        for item in pageList:
            print '   ========================='
            print '   PAGE NAME: ',
            print item['title']
            print '   PAGE ID:   ',
            print item['id']
            print '   ========================='

        return


    #
    #   List all pages on all spaces.
    #
    def dumpIt(self):

        spaces = self.getAllSpaces()
        for space in spaces:
            print '========================='
            print space
            print 'SPACE NAME: ',
            print space['name']
            print 'SPACE KEY:  ',
            print space['key']
            self.listSpacePages(space.get('key'))
            print '========================='

        return


    #
    #   Get a page using the confluence ID.
    #
    def getPageById(self, pageId=None):

        try:
            pageItem = self.__server.confluence2.getPage(self.__token, pageId)
        except:
            if self.__verbose:
                print 'Error function:  getPageById'
                print 'Error Confluence function:  confluence2.getPage()'
                print 'Confluence error: ',
                print sys.exc_info()
            pageItem = {}

        return pageItem



    #
    #   Get page data using the page name and space name.  Regardless
    #   of implied hierarchy, all pages are keyed directly to the space
    #   they are in, even if another page is listed as the parent of this
    #   page.
    #
    def getPage(self, spaceKey=None, pageTitle=None):

        #############################
        #
        #   If the page is passed in as a full path,
        #   this will figure out what the page name
        #   is.
        #
        pagePathList = pageTitle.split('/')

        if ( len(pagePathList) > 1 ):
           pageTitle = swing[len(pagePathList) - 1]
        else:
           pageTitle = pagePathList[0]

        #
        #############################

        try:
            pageItem = self.__server.confluence2.getPage(self.__token, spaceKey, pageTitle)
        except:
            if self.__verbose:
                print 'Error function:  getPage'
                print 'Error Confluence function:  confluence2.getPage()'
                print 'Error input data:', spaceKey, pageTitle
                print 'Confluence error: ', sys.exc_info()
            pageItem = {}

        return pageItem



    #
    #   Get a list of every attachment on the page.
    #
    def getPageAttachments(self, pageId=None):

        try:
            attachmentList = self.__server.confluence2.getAttachments(self.__token, pageId)
        except:
            if self.__verbose:
                print 'Error function:  getPageAttachments'
                print 'Error Confluence function:  confluence2.getAttachments()'
                print 'Confluence error: ',
                print sys.exc_info()
            attachmentList = []

        return attachmentListList



    #
    #   initialize the page dictionary used to create or update a page.
    #
    def initializePage(self, space = None, title = None, content = None, parentId = None):

        cPage = {}
        cPage['space'] = space
        cPage['title'] = title
        cPage['content'] = content

        if (parentId is not None):
            cPage['parentId'] = parentId

        if self.__debug:
            print 'CPAGE',
            print cPage

        return cPage



    #
    #   Add the new page.
    #   nPage would probably have come out of initializePage()
    #
    def addNewPage(self, nPage = {}):

        try:
            result = self.__server.confluence2.storePage(self.__token, nPage)
        except:
            if self.__verbose:
                print 'Error function:  addNewPage'
                print 'Error Confluence function:  confluence2.storePage()'
                print 'Confluence error: ',
                print sys.exc_info()
            result = {}

        return result



    #
    #   Delete a page.  When a page is deleted, all of the attached
    #   items are deleted as well.
    #
    def deletePage(self, pageId = None):

        try:
            self.__server.confluence2.removePage(self.__token, pageId)
        except:
            print 'Error function:  deletePage'
            print 'Error Confluence function:  confluence2.removePage()'
            print 'Confluence error: ',
            print sys.exc_info()
            return False

        return True


    #
    #   Move a page.  Can be moved anywhere within confluence
    #   so you need to specify the space as well.
    #
    def movePage(self, srcSpaceKey = None, srcPageTitle = None,
                       trgSpaceKey = None, trgPageTitle = None,
                       position = 'append'):

        try:
            mvSrcPage = self.getPage(srcSpaceKey, srcPageTitle)
            mvTrgPage = self.getPage(trgSpaceKey, trgPageTitle)
        except:
            print 'Error function:  movePage'
            print 'Could not find source page or target page'
            return False

        try:
            if ( mvTrgPage is None or mvTrgPage == {} ):
                self.__server.confluence2.movePageToTopLevel(self.__token, mvSrcPage['id'], trgSpaceKey)
            else:
                self.__server.confluence2.movePage(self.__token,
                                                   mvSrcPage['id'],
                                                   mvTrgPage['id'],
                                                   position)
        except:
            print 'Error function:  movePage'
            print 'Error Confluence function:  confluence2.movePage()'
            print 'Error Data(source): ', srcSpaceKey, srcPageTitle
            print 'Error Data(taget): ', trgSpaceKey, trgPageTitle
            print 'Confluence error: ', sys.exc_info()
            return False

        return True



    #
    #   Do everything needed to initialze the page dictionary and then
    #   use the data to create the page.
    #
    def createPage(self, space, title, content, parentId):

        mypage = self.initializePage(space, title, content, parentId)
        pageData = self.addNewPage(mypage)
        return pageData

    #
    #   Initialize attachment dictionary so it can be used
    #   to create a new attachement.
    #
    def initializeAttachment(self, title):

        cAttch = {}

        try:
            cAttch['contentType'] = self.__myMime.guess_type(title, strict=False)[0]
        except:
            cAttch['contentType'] = 'text/plain'

        cAttch['title'] = title
        cAttch['comment'] = title
        cAttch['fileName'] = os.path.basename(title)

        return cAttch


    def addNewAttachment(self, contentId, attachment, atchData):

        try:
            result = self.__server.confluence2.addAttachment(self.__token, contentId, attachment, xmlrpclib.Binary(atchData))
        except:
            if self.__verbose:
                print 'Error function:  addNewAttachment'
                print 'Error Confluence function:  confluence2.addAttachment()'
                print 'Confluence error: ',
                print sys.exc_info()
            result = {}
        return result

    def createAttachment(self, spaceKey=None, pageTitle=None, title=None):

        if ((spaceKey is None) or (pageTitle is None) or (title is None)):
            err = {}

        if ( self.__parentId is None ):
           try:
               myPage = self.getPage(spaceKey, pageTitle)
               contentId = myPage['id']
           except:
               print 'Error function:  createAttachment'
               print '    Getting page contentID failed.'
               print '    ', spaceKey, pageTitle, title
               return {}
        else:
           contentId = self.__parentId

        atchData = self.readTheFile(title)

        cAttch = self.initializeAttachment(title)
        err = self.addNewAttachment(contentId, cAttch, atchData)

        return err


    def deleteAttachment(self, spaceKey=None, pageTitle=None, title=None):

        if ((spaceKey is None) or (pageTitle is None) or (title is None)):
            err = False

        try:
            myPage = self.getPage(spaceKey, pageTitle)
            contentId = myPage['id']
        except:
            print 'Error function:  deleteAttachment'
            print '    Getting page contentID failed.'
            return False

        try:
           err = self.__server.confluence2.removeAttachment(self.__token, contentId, title)
        except:
            print 'Error function:  deleteAttachment'
            print 'Error Confluence function:  confluence2.removeAttachment()'
            print 'Error Data: ', contentId, title
            print 'Confluence error: ', sys.exc_info()
            err = False

        return err



    #
    #   Move an attachment.  Just like moving a file.
    #
    def moveAttachment(self, oSpaceKey = None, oPageTitle = None, oName = None,
                             nSpaceKey = None, nPageTitle = None, nName = None):

        if ((oSpaceKey is None) or (oPageTitle is None) or (oName is None)):
            return False
        if ((nSpaceKey is None) or (nPageTitle is None) or (nName is None)):
            return False

        try:
            oMyPage = self.getPage(oSpaceKey, oPageTitle)
            nMyPage = self.getPage(nSpaceKey, nPageTitle)
        except:
            print 'Error function:  moveAttachment'
            print '    Getting page data failed.'
            return False

        try:
            err = self.__server.confluence2.moveAttachment(
                                                  self.__token,
                                                  oMyPage['id'], oName,
                                                  nMyPage['id'], nName)
        except:
            print 'Error function:  moveAttachment'
            print 'Error Confluence function:  confluence2.moveAttachment()'
            print 'Confluence error: ',
            print sys.exc_info()
            err = False



    #
    #   Rename an attachment.  Just like renaming a file.
    #
    def renameAttachment(self, SpaceKey = None, PageTitle = None,
                               oName = None, nName = None):

        if ((SpaceKey is None) or (PageTitle is None) or
            (oName is None) or (nName is None)):
            return False

        try:
            MyPage = self.getPage(SpaceKey, PageTitle)
        except:
            print 'Error function:  moveAttachment'
            print '    Getting page data failed.'
            return False

        try:
            err = self.__server.confluence2.moveAttachment(
                                                 self.__token,
                                                 MyPage['id'], oName,
                                                 MyPage['id'], nName)
        except:
            print 'Error function:  renameAttachment'
            print 'Error Confluence function:  confluence2.moveAttachment()'
            print 'Confluence error: ',
            print sys.exc_info()
            err = False



if (__name__ == '__main__'):
    server_url = 'http://172.16.10.81:8090/rpc/xmlrpc'
    cnfl = CONFLUENCE(server_url)
    #cnfl.deleteAttachment('testenv', 'PPT', 'boeing.ppt')
    #def removeAnonymousSpacePermission(self, spaceKey=None, perm=None):
    #print cnfl.newUser(userName='mojojojo', pw='itisi-mojojojo')
    print cnfl.newUser(userName='quato', pw='recall')
