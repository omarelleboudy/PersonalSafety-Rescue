class GlobalVar
{

  static Map<String, Object> dataStorage = new Map<String, Object>();

  static T Get<T>(String varName, T defaultValue)
  {
    if (dataStorage.containsKey(varName))
      return dataStorage[varName] as T;
    return defaultValue;
  }

  static void Set(String varName, Object value)
  {

    if (dataStorage.containsKey(varName))
      dataStorage.remove(varName);

    dataStorage.putIfAbsent(varName, () => value);

  }

}