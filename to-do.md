# To-do

Uma lista organizada dos próximos feitiços técnicos do `folderstamp`.

## Próximas prioridades

- [ ] Implementar uma ferramenta/rotina própria em Bash para codificar CIDv1/raw/BLAKE3 compatível com o digest BLAKE3-256 utilizado pelo Iroh: varints, codec raw `0x55`, multihash BLAKE3 `0x1e`, comprimento de 32 bytes e base32 multibase lowercase. Não depender de Python.
- [ ] Validar vetores de teste do encoder Bash contra uma implementação independente e contra Iroh, sem adicionar blobs ao armazenamento local.
- [ ] Implementar flag `--hash` para controlar quando o CID deve ser calculado.
- [ ] Registrar a data/hora exata no fim de cada snapshot.
- [ ] Adicionar opção para registrar o número do bloco Ethereum mais recente no momento do stamp.

## Modos de listagem

- [ ] Criar modo simples `.ls`, com rotação `.ls1`, `.ls2` etc.
- [ ] Criar `.folderstamp.listed` para evitar listar novamente arquivos já snapshotados anteriormente.
- [ ] Avaliar integração futura com uma biblioteca de nomes incrementais/untitled para evitar sobrescrever arquivos.

## Desktop e ambiente gráfico

- [ ] Quando o stamp for feito no Desktop, detectar o ambiente gráfico quando possível.
- [ ] Em Cinnamon, registrar o wallpaper atual com:
  ```sh
  gsettings get org.cinnamon.desktop.background picture-uri | tr -d "'"
  ```
- [ ] Pesquisar como registrar posições e ícones de itens no Desktop por ambiente gráfico.
- [ ] Fazer fallback silencioso quando não houver desktop environment detectado.

## Recursividade e escopo

- [ ] No modo recursivo, registrar também metadados das pastas, não apenas dos arquivos.
- [ ] Adicionar opção para limitar profundidade de recursão.
- [ ] Adicionar opção para escolher um número customizado para `.folderstamp`, recusando números já existentes.

## Android, Termux e armazenamento SD

- [ ] Implementar suporte a destinos em cartão SD no Termux, respeitando as restrições de armazenamento do Android e sem exigir root.
- [ ] Investigar os fluxos ADB/SAF/Shizuku e a diferença entre o armazenamento privado do Termux e diretórios removíveis compartilhados.
- [ ] Definir uma interface de destino separada da raiz examinada, para que o snapshot possa ser gerado no armazenamento privado e gravado no SD por um backend autorizado.
- [ ] Quando estiver no computador (Comp), preparar o PR 2/2 para suporte a cartão SD no Termux: **"When at Comp, prep PR 2/2."**
- [ ] Validar o fluxo em Android real, incluindo cartão removível, permissões revogadas, volume desmontado e falhas durante a cópia.

## Portabilidade, integridade e testes

- [ ] Validar a execução em Termux real (Android/Bionic), incluindo shell interativo e não interativo.
- [ ] Testar o instalador em Termux com e sem uma instalação anterior.
- [ ] Adicionar testes automatizados para nomes com espaços, tabs, quebras de linha, Unicode, caracteres de controle e diretórios vazios.
- [ ] Testar concorrência entre duas chamadas simultâneas de `save`.
- [ ] Testar interrupção abrupta/queda de energia em cada fronteira entre escrita do manifesto, `sync` e atualização do checkpoint; confirmar que `.incomplete` permite retomar sem duplicar entradas.
- [ ] Testar retomada com árvore de origem alterada, arquivo removido, arquivo substituído, link simbólico quebrado e checkpoint truncado/corrompido.
- [ ] Verificar comportamento em sistemas de arquivos sem suporte confiável a renomeação atômica.
- [ ] Validar o fallback CIDv0 contra Kubo em arquivos vazios, pequenos e acima do limite de chunking; o fallback atual só implementa UnixFS/DAG-PB single-block.
- [ ] Completar a semântica de `.folderstampignore` ou documentar com testes as diferenças em relação ao Git; o matcher atual é parcial e não reproduz todos os casos do gitignore.
- [ ] Testar assets e instalação de ferramentas externas por arquitetura, ABI/libc e plataforma antes de habilitar autodownload em cada plataforma.
- [ ] Verificar assinaturas/checksums dos downloads de Kubo, Iroh e outras ferramentas; comparar com os digests publicados pelo projeto antes de extrair ou instalar.
- [ ] Testar a seleção de assets Android/Termux: exibir `uname -m`, pedir confirmação explícita, executar teste de versão e preservar a instalação anterior quando o binário não for executável.
- [ ] Avaliar uma integração de validação opcional com Iroh/Kubo que compare digest/CID sem gravar o conteúdo em armazenamento local; manter essa validação fora do caminho normal de snapshot.
- [ ] Expandir a detecção de package managers além de `apt`, `dnf`, `pacman`, `apk`, `zypper`, `pkg` e Cygwin setup.

## Controle de versão alternativo

- [ ] Melhorar suporte ao Gitoxide para extrair branch/remotes sem depender do Git clássico.
- [ ] Expandir suporte Pijul para registrar remotes, identidade do repositório e mudanças pendentes.
- [ ] Adicionar testes simulando ambientes com apenas `git`, apenas `gix`, apenas `pijul` e nenhum VCS instalado.

## Plataformas adicionais

- [ ] Testar o instalador em macOS real com e sem Homebrew.
- [ ] Testar comandos BSD com `pkg` e `pkg_add` em shells não-GNU.
- [ ] Documentar o que é possível automatizar em Zircon/Fuchsia sem fingir universalidade fake.

## Documentação

- [x] Criar `README.md` com instalação, uso, exemplos e troubleshooting.
- [x] Documentar diferenças e limitações conhecidas de Termux, especialmente a incompatibilidade presumida de binários Linux/glibc com Android/Bionic.
- [x] Documentar as limitações do fallback CIDv0 single-block e do matcher `.folderstampignore`.
- [x] Documentar snapshots `.incomplete`, checkpoints e o comando de retomada.
- [x] Registrar o plano de suporte a SD no Termux para o PR 2/2.
