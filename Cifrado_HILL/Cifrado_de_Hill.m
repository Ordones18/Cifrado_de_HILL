% Función principal
function hill_cipher_gui()
    % Crear la ventana de la interfaz gráfica
    fig = figure('Name', 'Cifrado Hill', 'Position', [500, 300, 400, 400]);

    % Etiquetas y campos de texto para el mensaje y la clave
    uicontrol('Style', 'text', 'Position', [50, 290, 300, 20], 'String', 'Mensaje a cifrar:', 'HorizontalAlignment', 'left');
    inputMessage = uicontrol('Style', 'edit', 'Position', [50, 260, 300, 25]);

    uicontrol('Style', 'text', 'Position', [50, 220, 300, 20], 'String', 'Clave 2x2 Ejemplo:(0,0;0,0)', 'HorizontalAlignment', 'left');
    inputKey = uicontrol('Style', 'edit', 'Position', [50, 190, 300, 25]);

    % Botones para cifrar y descifrar
    uicontrol('Style', 'pushbutton', 'Position', [50, 130, 120, 30], 'String', 'Cifrar', 'Callback', @(~, ~) cifrarCallback());
    uicontrol('Style', 'pushbutton', 'Position', [200, 130, 120, 30], 'String', 'Descifrar', 'Callback', @(~, ~) descifrarCallback());

    % Área de resultado para mostrar el cifrado o descifrado
    resultBox = uicontrol('Style', 'text', 'Position', [50, 50, 300, 40], 'String', '', 'HorizontalAlignment', 'left');

    % Mostrar el crédito al final de la interfaz
    uicontrol('Style', 'text', 'Position', [50, 10, 300, 20], 'String', 'Universidad Nacional de Chimborazo', 'HorizontalAlignment', 'center');

    % Función de cifrado
    function cifrarCallback()
        % Obtener el mensaje y la clave ingresados por el usuario
        mensaje = get(inputMessage, 'String');
        claveStr = get(inputKey, 'String');
        clave = str2num(['[', claveStr, ']']);

        % Validar entrada del usuario
        if isempty(mensaje) || isempty(clave) || ~isequal(size(clave), [2, 2])
            set(resultBox, 'String', 'Por favor ingresa un mensaje y una clave válida.');
            return;
        end

        % Realizar el cifrado
        mensajeCifrado = cifrarHill(mensaje, clave);
        % Mostrar el resultado cifrado
        set(resultBox, 'String', ['Cifrado: ', mensajeCifrado]);
    end

    % Función de descifrado
    function descifrarCallback()
        % Obtener el mensaje y la clave ingresados por el usuario
        mensaje = get(inputMessage, 'String');
        claveStr = get(inputKey, 'String');
        clave = str2num(['[', claveStr, ']']);

        % Validar entrada del usuario
        if isempty(mensaje) || isempty(clave) || ~isequal(size(clave), [2, 2])
            set(resultBox, 'String', 'Por favor ingresa un mensaje y una clave válida.');
            return;
        end

        % Intentar descifrar el mensaje
        try
            mensajeDescifrado = descifrarHill(mensaje, clave);
            % Mostrar el resultado descifrado
            set(resultBox, 'String', ['Descifrado: ', mensajeDescifrado]);
        catch
            % Mostrar error si la clave no tiene inversa modular
            set(resultBox, 'String', 'Error: la clave no tiene inversa modular.');
        end
    end
end

% Función para cifrar usando el cifrado de Hill
function mensajeCifrado = cifrarHill(mensaje, clave)
    % Preprocesar el mensaje para eliminar caracteres no válidos y completar con X
    mensaje = preprocessMessage(mensaje);
    % Convertir el mensaje a formato numérico (A=0, B=1, ..., Z=25)
    mensajeNumerico = charToNum(mensaje);
    % Aplicar la matriz clave para cifrar el mensaje
    mensajeCifradoNumerico = mod(clave * reshape(mensajeNumerico, 2, []), 26);
    % Convertir el mensaje cifrado a formato de texto
    mensajeCifrado = numToChar(mensajeCifradoNumerico(:)');
end

% Función para descifrar usando el cifrado de Hill
function mensajeDescifrado = descifrarHill(mensaje, clave)
    % Preprocesar el mensaje para eliminar caracteres no válidos y completar con X
    mensaje = preprocessMessage(mensaje);
    % Convertir el mensaje a formato numérico (A=0, B=1, ..., Z=25)
    mensajeNumerico = charToNum(mensaje);

    % Calcular la inversa modular de la clave
    detClave = mod(det(clave), 26); % Determinante de la matriz clave mod 26
    inversaDetClave = modInverse(detClave, 26); % Inversa modular del determinante
    adjClave = round(det(clave) * inv(clave)); % Matriz adjunta de la clave
    claveInversa = mod(inversaDetClave * adjClave, 26); % Clave inversa mod 26

    % Aplicar la matriz inversa para descifrar el mensaje
    mensajeDescifradoNumerico = mod(claveInversa * reshape(mensajeNumerico, 2, []), 26);
    % Convertir el mensaje descifrado a formato de texto
    mensajeDescifrado = numToChar(mensajeDescifradoNumerico(:)');
end

% Convertir caracteres a números (A=0, B=1, ..., Z=25)
function nums = charToNum(chars)
    nums = double(upper(chars)) - double('A');
end

% Convertir números a caracteres (0=A, 1=B, ..., 25=Z)
function chars = numToChar(nums)
    chars = char(mod(nums, 26) + double('A'));
end

% Preprocesar el mensaje (convertir a mayúsculas y completar con X si es necesario)
function mensaje = preprocessMessage(mensaje)
    % Convertir el mensaje a mayúsculas y eliminar caracteres no alfabéticos
    mensaje = upper(regexprep(mensaje, '[^A-Z]', ''));
    % Completar el mensaje con 'X' si su longitud no es múltiplo de 2
    if mod(length(mensaje), 2) ~= 0
        mensaje = [mensaje, 'X'];
    end
end

% Calcular la inversa modular
function inv = modInverse(a, m)
    % Utilizar el algoritmo extendido de Euclides para calcular la inversa modular
    [g, x, ~] = gcd(a, m);
    if g ~= 1
        error('No existe inversa modular.');
    end
    inv = mod(x, m);
end

