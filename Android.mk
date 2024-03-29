LOCAL_PATH := $(call my-dir)
#LOCAL_PATH := /cygdrive/d/android/code/pela/hexen/hexen/project/jni/application
include $(CLEAR_VARS)

LOCAL_MODULE := application
APPDIR := $(shell readlink $(LOCAL_PATH)/src)

APP_SUBDIRS := $(patsubst $(LOCAL_PATH)/%, %, $(shell find $(LOCAL_PATH)/$(APPDIR) -path '*/.svn' -prune -o -type d -print))
ifneq ($(APPLICATION_SUBDIRS_BUILD),)
APPLICATION_SUBDIRS_BUILD_NONRECURSIVE := $(addprefix $(APPDIR)/, $(filter-out %/*, $(APPLICATION_SUBDIRS_BUILD)))
APPLICATION_SUBDIRS_BUILD_RECURSIVE := $(patsubst %/*, %, $(filter %/*,$(APPLICATION_SUBDIRS_BUILD)))
APPLICATION_SUBDIRS_BUILD_RECURSIVE := $(foreach FINDDIR, $(APPLICATION_SUBDIRS_BUILD_RECURSIVE), $(shell find $(LOCAL_PATH)/$(APPDIR)/$(FINDDIR) -path '*/.svn' -prune -o -type d -print))
APPLICATION_SUBDIRS_BUILD_RECURSIVE := $(patsubst $(LOCAL_PATH)/%, %, $(APPLICATION_SUBDIRS_BUILD_RECURSIVE) )
APP_SUBDIRS := $(APPLICATION_SUBDIRS_BUILD_NONRECURSIVE) $(APPLICATION_SUBDIRS_BUILD_RECURSIVE)
endif

LOCAL_CFLAGS :=
LOCAL_C_INCLUDES :=

ifeq ($(CRYSTAX_TOOLCHAIN)$(NDK_R5_TOOLCHAIN),)
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../stlport/stlport
endif

LOCAL_C_INCLUDES += $(foreach D, $(APP_SUBDIRS), $(LOCAL_PATH)/$(D)) \
					$(LOCAL_PATH)/../sdl-$(SDL_VERSION)/include \
					$(foreach L, $(COMPILED_LIBRARIES), $(LOCAL_PATH)/../$(L)/include) \
					$(LOCAL_PATH)/src/include

LOCAL_CFLAGS += -include $(LOCAL_PATH)/../sdl_fake_stdout/include/SDL_android_printf.h

LOCAL_CFLAGS += $(APPLICATION_ADDITIONAL_CFLAGS) -DNORMALUNIX -DUSE_SDL  

#Change C++ file extension as appropriate
LOCAL_CPP_EXTENSION := .cpp

#LOCAL_SRC_FILES := $(foreach F, $(APP_SUBDIRS), $(addprefix $(F)/,$(notdir $(wildcard $(LOCAL_PATH)/$(F)/*.cpp))))
#LOCAL_SRC_FILES += $(foreach F, $(APP_SUBDIRS), $(addprefix $(F)/,$(notdir $(wildcard $(LOCAL_PATH)/$(F)/*.c))))
SRCS := a_action.c  \
am_map.c  \
ct_chat.c  \
d_net.c  \
f_finale.c  \
g_game.c  \
h2_main.c  \
in_lude.c  \
info.c  \
m_misc.c  \
mn_menu.c  \
mn_keynames.c  \
p_acs.c  \
p_anim.c  \
p_ceilng.c  \
p_doors.c  \
p_enemy.c  \
p_floor.c  \
p_inter.c  \
p_lights.c  \
p_map.c  \
p_maputl.c  \
p_mobj.c  \
p_plats.c  \
p_pspr.c  \
p_setup.c  \
p_sight.c  \
p_spec.c  \
p_switch.c  \
p_telept.c  \
p_things.c  \
p_tick.c  \
p_user.c  \
po_man.c  \
i_video.c \
i_sdlvideo.c \
i_fbsdvideo.c \
i_main.c \
i_system.c \
i_sound.c \
qmus2mid.c \
i_sdlsound.c \
i_netstub.c \
m_fixed.c \
r_bsp.c  \
r_data.c  \
r_draw.c  \
r_main.c  \
r_plane.c  \
r_segs.c  \
r_things.c  \
sb_bar.c  \
sc_man.c  \
sn_sonix.c  \
sounds.c  \
st_start_stub.c  \
sv_save.c  \
tables.c  \
template.c  \
v_video.c  \
w_wad.c  \
z_zone.c

LOCAL_SRC_FILES =  $(foreach F, $(SRCS), $(addprefix src/src/,$(F))) 
ifneq ($(APPLICATION_CUSTOM_BUILD_SCRIPT),)
LOCAL_SRC_FILES := dummy.c
endif

LOCAL_SHARED_LIBRARIES := sdl-$(SDL_VERSION) $(filter-out $(APP_AVAILABLE_STATIC_LIBS), $(COMPILED_LIBRARIES))

LOCAL_STATIC_LIBRARIES := $(filter $(APP_AVAILABLE_STATIC_LIBS), $(COMPILED_LIBRARIES))

LOCAL_STATIC_LIBRARIES += stlport sdl_fake_stdout

LOCAL_LDLIBS :=  -ldl -llog -lz -lm

LOCAL_LDFLAGS := -Lobj/local/armeabi -Wl,-u,_SDL_ANDROID_initFakeStdout

LOCAL_LDFLAGS += $(APPLICATION_ADDITIONAL_LDFLAGS)

LIBS_WITH_LONG_SYMBOLS := $(strip $(shell \
	for f in $(LOCAL_PATH)/../../obj/local/armeabi/*.so ; do \
		if echo $$f | grep "libapplication[.]so" > /dev/null ; then \
			continue ; \
		fi ; \
		if [ -e "$$f" ] ; then \
			if nm -g $$f | cut -c 12- | egrep '.{128}' > /dev/null ; then \
				echo $$f | grep -o 'lib[^/]*[.]so' ; \
			fi ; \
		fi ; \
	done \
) )

ifneq "$(LIBS_WITH_LONG_SYMBOLS)" ""
$(foreach F, $(LIBS_WITH_LONG_SYMBOLS), \
$(info Library $(F): abusing symbol names are: \
$(shell nm -g $(LOCAL_PATH)/../../obj/local/armeabi/$(F) | cut -c 12- | egrep '.{128}' ) ) \
$(info Library $(F) contains symbol names longer than 128 bytes, \
YOUR CODE WILL DEADLOCK WITHOUT ANY WARNING when you'll access such function - \
please make this library static to avoid problems. ) )
$(error Detected libraries with too long symbol names. Remove all files under project/obj/local/armeabi, make these libs static, and recompile)
endif

APP_LIB_DEPENDS := $(foreach LIB, $(LOCAL_SHARED_LIBRARIES), $(abspath $(LOCAL_PATH)/../../obj/local/armeabi/lib$(LIB).so)) 
APP_LIB_DEPENDS += $(foreach LIB, $(LOCAL_STATIC_LIBRARIES), $(abspath $(LOCAL_PATH)/../../obj/local/armeabi/lib$(LIB).a))

include $(BUILD_SHARED_LIBRARY)

ifneq ($(APPLICATION_CUSTOM_BUILD_SCRIPT),)

# TODO: here we're digging inside NDK internal build system, that's not portable
# NDK r5b provided the $(PREBUILT_SHARED_LIBRARY) target, however it requires .so file to be already present on disk
# Also I cannot just launch AndroidBuild.sh from makefile because other libraries are not rebuilt and linking will fail

LOCAL_PATH_SDL_APPLICATION := $(LOCAL_PATH)

.NOTPARALLEL: $(realpath $(LOCAL_PATH)/../../obj/local/armeabi/libapplication.so) $(LOCAL_PATH)/src/libapplication.so

# Enforce rebuilding
$(shell rm -f $(LOCAL_PATH)/src/libapplication.so)
$(shell mkdir -p $(LOCAL_PATH)/../../obj/local/armeabi)
$(shell touch $(LOCAL_PATH)/../../obj/local/armeabi/libapplication.so)

$(LOCAL_PATH)/src/libapplication.so: $(LOCAL_PATH)/src/AndroidBuild.sh $(LOCAL_PATH)/src/AndroidAppSettings.cfg $(APP_LIB_DEPENDS)
	echo Launching script $(LOCAL_PATH_SDL_APPLICATION)/AndroidBuild.sh
	cd $(LOCAL_PATH_SDL_APPLICATION)/src && ./AndroidBuild.sh

$(realpath $(LOCAL_PATH)/../../obj/local/armeabi/libapplication.so): $(LOCAL_PATH)/src/libapplication.so OVERRIDE_CUSTOM_LIB
	cp -f $< $@

.PHONY: OVERRIDE_CUSTOM_LIB

OVERRIDE_CUSTOM_LIB:

endif
