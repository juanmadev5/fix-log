class AppStrings {
  static const cancel = 'Cancelar';
  static const edit = 'Editar';
  static const delete = 'Eliminar';
  static const newLabel = 'Nuevo';
  static const update = 'Actualizar';
  static const required = 'Requerido';
  static const cannotBeUndone = 'Esta acción no se puede deshacer.';

  static const appTitle = 'Fix Log';
  static const lightMode = 'Modo claro';
  static const darkMode = 'Modo oscuro';
  static const logout = 'Cerrar sesión';
  static const logoutConfirmation = '¿Estás seguro que deseas cerrar sesión?';
  static const exit = 'Salir';
  static const customersTab = 'Clientes';
  static const expensesTab = 'Gastos';
  static const reportsTab = 'Reportes';

  static const email = 'Correo electrónico';
  static const enterYourEmail = 'Ingresa tu correo';
  static const password = 'Contraseña';
  static const enterYourPassword = 'Ingresa tu contraseña';

  static const welcome = 'Bienvenido';
  static const loginSubtitle = 'Inicia sesión para continuar';
  static const login = 'Ingresar';
  static const noAccountYet = '¿No tienes cuenta? ';
  static const createAccount = 'Crear cuenta';

  static const registerTitle = 'Crear cuenta';
  static const newAccount = 'Nueva cuenta';
  static const registerSubtitle = 'Completa los datos para registrarte';
  static const passwordMinLength = 'Mínimo 6 caracteres';
  static const register = 'Registrar';
  static const alreadyHaveAccount = '¿Ya tienes cuenta? ';
  static const signIn = 'Iniciar sesión';

  static const noCustomers = 'Sin clientes';
  static const noCustomersSubtitle = 'Agrega tu primer cliente con el botón +';
  static const deleteCustomerTitle = 'Eliminar cliente';
  static String deleteCustomerConfirmation(String name) =>
      '¿Eliminar a "$name"? $cannotBeUndone';
  static const editCustomer = 'Editar cliente';
  static const newCustomer = 'Nuevo cliente';
  static const fullName = 'Nombre completo';
  static const enterName = 'Ingresa el nombre';
  static const enterEmail = 'Ingresa el correo';
  static const phoneNumber = 'Teléfono';
  static const enterPhoneNumber = 'Ingresa el teléfono';
  static const saveCustomer = 'Guardar cliente';

  static const noExpenses = 'Sin gastos';
  static const noExpensesSubtitle = 'Registra tu primer gasto con el botón +';
  static const deleteExpenseTitle = 'Eliminar gasto';
  static String deleteExpenseConfirmation(String title) =>
      '¿Eliminar "$title"? $cannotBeUndone';
  static const editExpense = 'Editar gasto';
  static const newExpense = 'Nuevo gasto';
  static const title = 'Título';
  static const enterTitle = 'Ingresa el título';
  static const details = 'Detalles';
  static const enterDetails = 'Ingresa los detalles';
  static const priceInGs = 'Precio (Gs.)';
  static const quantity = 'Cantidad';
  static const saveExpense = 'Guardar gasto';

  static const noReports = 'Sin reportes';
  static const noReportsSubtitle = 'Crea tu primer reporte con el botón +';
  static const deleteReportTitle = 'Eliminar reporte';
  static const deleteReportConfirmation =
      '¿Eliminar este reporte? $cannotBeUndone';
  static const completed = 'Completado';
  static const pending = 'Pendiente';
  static const paid = 'Pagado';
  static const unpaid = 'Sin pagar';
  static const editReport = 'Editar reporte';
  static const newReport = 'Nuevo reporte';
  static const selectCustomer = 'Seleccionar cliente';
  static const selectACustomer = 'Selecciona un cliente';
  static const workDetails = 'Detalles del trabajo';
  static const workCostInGs = 'Costo del trabajo (Gs.)';
  static const enterCost = 'Ingresa el costo';
  static const date = 'Fecha';
  static const status = 'Estado';
  static const completedSubtitleOn = 'El servicio fue completado';
  static const completedSubtitleOff = 'Pendiente de completar';
  static const paidSubtitleOn = 'El servicio fue pagado';
  static const paidSubtitleOff = 'Pendiente de pago';
  static const saveReport = 'Guardar reporte';
  static const searchCustomerHint = 'Buscar por nombre, email o teléfono…';
  static const noResults = 'Sin resultados';

  static const serverErrorFallback = 'Error del servidor. Inténtalo más tarde.';
  static const sessionExpired = 'Sesión expirada. Inicia sesión de nuevo.';
  static const forbiddenAction = 'No tienes permiso para esta acción.';
  static const noConnection =
      'Sin conexión. Verifica tu red e inténtalo de nuevo.';
  static const unexpectedError =
      'Ocurrió un error inesperado. Inténtalo de nuevo.';
  static const emailAlreadyRegistered =
      'Ya existe una cuenta con ese correo electrónico.';
  static const invalidCredentials =
      'El correo o la contraseña son incorrectos.';
  static const validationFailed = 'Revisá los datos ingresados.';
  static const customerNotFound = 'El cliente no fue encontrado.';
  static const expenseNotFound = 'El gasto no fue encontrado.';
  static const reportNotFound = 'El reporte no fue encontrado.';
  static const unexpectedErrorFallback =
      'Algo salió mal. Reinicia la aplicación.';
}
