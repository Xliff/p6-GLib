#include <stdio.h>
#include "glib.h"

int main(void)
{
    GKeyFile *key_file;
    GError *error;
    gsize length;

    gchar *str_value;
    gint int_value;
    gdouble double_value;

    key_file = g_key_file_new();
    error = NULL;

    guint group, key;

    printf("Checking...\n");
    if(!g_key_file_load_from_file(key_file,
                                  "test.ini",
                                  G_KEY_FILE_KEEP_COMMENTS |
                                  G_KEY_FILE_KEEP_TRANSLATIONS,
                                  &error))
    {
        printf("Not found!\n");
        g_debug("%s", error->message);
    }
    else
    {
        printf("i yam here!\n");
        str_value = g_key_file_get_string(key_file,
                                          "test",
                                          "str_value",
                                          &error);
        int_value = g_key_file_get_integer(key_file,
                                           "test",
                                           "int_value",
                                           &error);
        double_value = g_key_file_get_double(key_file,
                                             "test",
                                             "double_value",
                                             &error);

        g_debug("str: %s \nint: %d \ndouble: %f\n",
                str_value, int_value, double_value);
        printf("str: %s \nint: %d \ndouble: %f\n",
                str_value, int_value, double_value);

        g_key_file_set_string(key_file, "test", "str_value", str_value);
        g_key_file_set_integer(key_file, "test", "int_value", int_value + 1);
        g_key_file_set_integer(key_file, "test", "double_value", double_value * 2);

        g_debug("%s", g_key_file_to_data(key_file, &length, &error));
        printf("%s", g_key_file_to_data(key_file, &length, &error));


        gsize num_groups, num_keys;
        gchar **groups, **keys, *value;


        groups = g_key_file_get_groups(key_file, &num_groups);
        for(group = 0;group < num_groups;group++)
        {
            g_debug("group %u/%lu: \t%s", group, num_groups - 1, groups[group]);
            printf("group %u/%lu: \t%s\n", group, num_groups - 1, groups[group]);


            keys = g_key_file_get_keys(key_file, groups[group], &num_keys, &error);
            for(key = 0;key < num_keys;key++)
            {
                value = g_key_file_get_value(key_file,
                                             groups[group],
                                             keys[key],
                                             &error);
                g_debug("\t\tkey %u/%lu: \t%s => %s", key, num_keys - 1, keys[key], value);
                printf("\t\tkey %u/%lu: \t%s => %s\n", key, num_keys - 1, keys[key], value);
            }
        }
    }

    return 0;
}
