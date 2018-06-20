## @package genPortalUUID
#  Generate UUID's for cBioPortal study id's
#  and repository paths
#
#  The UUID's have three components
#    DIVISION/DIFF01/DIFF02/ID
#
#    DIVISION == Namespace id of group: for platform informatics
#                pi
#    DIFF01   == 2 2 digit hex codes to scatter studies
#    DIFF02      and keep total number in any one folder small
#    ID       == ID for study/project/requeset should be
#                globally unique but manditory requirement is
#                that the full UUID is unique
#
#  E.g.:
#        pi/f5/b0/5a77e30b
#
#  Two (2) version:
#    1) Time based. Generate a UUID based on time
#       Counter has sec resolution so can not call
#       more frequently then once per sec. 8 hex digits
#       so 2^32 or 4.3*10^9 codes
#
#    2) Name based. Uses supplied name for ID. Diffusion
#       can be based on name or on seperately suppled string.
#       This allows related projects to be grouped
#
#  E.g.
#

import uuid
import re

DIVISION="pi"
DIVISION_URI=DIVISION+".mskcc.org"
DIVISION_UUID=uuid.uuid5(uuid.NAMESPACE_DNS,DIVISION_URI)
FILESEP=""
PATHSEP="/"

def makeDirectoryString(hex):
    # Make a two level folder
    # from the first 4 hex digits of hex
    # Prepend the DIVISION code
    # e.g.:
    #        pi/e5/13
    #
    return DIVISION+PATHSEP+hex[:2]+PATHSEP+hex[2:4]

def cvtToPortalStudyID(uu1,uu2):
    return uu1.replace(PATHSEP,"_")+"_"+uu2

def generateTimeBasedPortalUUID(namespaceUUID=DIVISION_UUID):
    uu_diff=makeDirectoryString(uuid.uuid4().hex[:4])
    uu=uuid.uuid1(0,0)
    uu_unique=uu.hex[:2]+uu.hex[15]+uu.hex[8:12]+uu.hex[3]
    return (uu_diff+PATHSEP+uu_unique,cvtToPortalStudyID(uu_diff,uu_unique))

def generateNameBasedPortalUUID(name,diffusion="",namespaceUUID=DIVISION_UUID):
    if diffusion=="":
        uu_diff=makeDirectoryString(uuid.uuid5(namespaceUUID,name).hex[:4])
    else:
        uu_diff=makeDirectoryString(uuid.uuid5(namespaceUUID,diffusion).hex[:4])
    proj_name = 'p'+name
    return (uu_diff+PATHSEP+proj_name,cvtToPortalStudyID(uu_diff,proj_name))

def generateIGOBasedPortalUUID(igoRequest):
    #
    # Group related IGO projects together
    # e.g.:
    #    Proj_01234
    #    Proj_01234_C
    #    Proj_01234_E
    #    ...
    # would all get sorted into same folder

    if igoRequest.startswith("Proj_"):
        igoRequest=igoRequest[5:]

    projNum=re.search('(\d+)',igoRequest)
    if projNum:
        prefix=projNum.group(0)
    else:
        prefix=igoRequest
    return generateNameBasedPortalUUID(igoRequest,prefix)

