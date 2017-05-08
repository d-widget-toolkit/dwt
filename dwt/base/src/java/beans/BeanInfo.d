module java.beans.BeanInfo;

import java.beans.BeanDescriptor;
import java.beans.PropertyDescriptor;
import java.lang.all;

interface BeanInfo {
    static const int ICON_COLOR_16x16 = 0;
    static const int ICON_COLOR_32x32 = 0;
    static const int ICON_MONO_16x16 = 0;
    static const int ICON_MONO_32x32 = 0;

    BeanInfo[] getAdditionalBeanInfo();
    BeanDescriptor getBeanDescriptor();
    int getDefaultEventIndex();
    int getDefaultPropertyIndex();
    //EventSetDescriptor[] getEventSetDescriptors();
    //Image getIcon(int iconKind);
    //MethodDescriptor[] getMethodDescriptors();
    PropertyDescriptor[] getPropertyDescriptors();
}



